module DW

  module PurchaseEmailParsing
    
    class PurchaseEmailParser
      def initialize(store)
        @store = store
        @parser = create_parser store
      end

      def create_parser(store)
        parser_class_name = "#{store.name.capitalize}EmailParser"
        parser_class = Object.const_get parser_class_name

        parser_class.send :new,store
      end

      def parse(emails)
        @parser.parse emails
      end

      # Extend the method_missing method to enable purchase email parser
      # to act as a shell for email parser classes.
      #
      def method_missing(method,*args,&block)

        if @parser.respond_to? method
          @parser.send method,*args,&block
        else
          super
        end
      end
    end 



    class AmazonEmailParser
      
      def initialize(store)
        @is_digital = store[:email].scan("digital").present?
      end
      
      def find_products_on_amazon(product_ids)
        products = {}

        product_ids.in_groups_of(10,false).each do |group|
        begin
          AmazonProductSearch.lookup_products(group).each do |product|
            products[product.product_id] = product
          end
    
        rescue => ex
          puts ex.message
        ensure
          sleep 1.0
        end
        end

        products
      end

      def search_products_on_amazon(product_names)
        products = {}

        product_names.each do |product_name|
        begin
          product = AmazonProductSearch.fetch_products("\"#{product_name}\"",1,false).first
          products[product_name] = product if product

        rescue => ex
          puts ex.message
        ensure
          sleep 1.0
        end
        end

        #product_names.in_groups_of(10,false).each do |group|
        #  hydra = Typhoeus::Hydra.new :max_concurrency => 1

        #  group.each do |product_name|
        #    request = Typhoeus::Request.new(
        #                AmazonProductSearch.fetch_products("\"#{product_name}\"",1,true),
        #                :connect_timeout => 2000,
        #                :timeout => 3500)

        #    request.on_complete do |response| 
        #      begin
        #        item = Amazon::Ecs::Response.new(response.body).items.first

        #        if item
        #          product = AmazonProduct.new(item)
        #          products[product_name] = product
        #        end
        #      rescue => ex
        #      end
        #    end 

        #    hydra.queue request
        #  end #group

        #  hydra.run
        #  #sleep 1.5
        #end #groups

        products
      end

      def initial_purchase_hash(key,text,email,search_by_name=true)
        {:asn_key => key,
          :bought_at => email.date,
          :text => text,
          :message_id => email.message_id,
          :search_by_name => search_by_name}
      end

      def parse_digital_email(email)
        purchases = []
        text = email.text
        regex = email.is_text_html? ?
                  /www.amazon.com\/gp\/product\/(\w+)[[:print:]]+strong>/ :
                  /^([[:print:]]+\r{0,1}\n{0,1}[[:print:]]+) \[/

        product_ids = text.scan(regex).flatten.uniq

        product_ids.each do |product_id|
          product_id = product_id.gsub(/\n|\r/," ")
          purchases << initial_purchase_hash(product_id,text,email,!email.is_text_html?)
        end

        purchases
      end

      def parse_offline_email(email)
        purchases = []
        text = email.text
        regex = email.is_text_html? ?
                  /<b>"([[:print:]]+\r{0,1}\n{0,1}[[:print:]]+)"<\/b>/ :
                  /[\d]+ "(.+)"/

        product_names = text.
                          scan(regex).
                          flatten.
                          uniq.
                          compact

        product_names.each do |product_name|
          product_name = product_name.gsub(/\n|\r/," ")
          purchases << initial_purchase_hash(product_name,text,email)
        end

        purchases
      end

      def parse(emails)
        purchases = []

        emails.each do |email|
          purchases += @is_digital ? 
                        parse_digital_email(email) : 
                        parse_offline_email(email)
        end

        amazon_products = {}

        ids,names = purchases.group_by{|p| p[:search_by_name]}.
                      values_at(false,true).
                      map{|group| group.map{|p| p[:asn_key]} if group}

        amazon_products.merge!(find_products_on_amazon(ids)) if ids.present?
        amazon_products.merge!(search_products_on_amazon(names)) if names.present?


        purchases.map do |purchase|
          next unless product = amazon_products[purchase[:asn_key]]

          purchase.merge!({
            :title => product.title,
            :source_url => product.page_url,
            :orig_image_url => product.large_image_url,
            :orig_thumb_url => product.medium_image_url,
            :external_id => product.custom_product_id})
        end.compact
      end
    end


    class ItunesEmailParser
      
      def initialize(store)
      end
      
      def find_products_on_itunes(product_ids)
        products = {}

        product_ids.in_groups_of(10,false).each do |group|
          Itunes.lookup(group).each do |product|
            products[product.product_id] = product
          end
        end

        products
      end

      def parse(emails)
        purchases = []

        emails.each do |email|
          text = email.text
          product_ids = text.
                          scan(/addUserReview?[^(]+&id=([D\d]+)/).
                          flatten.
                          uniq.
                          map{|id| id.to_s.gsub("3D","")}
          product_ids.each do |product_id|
            purchases << {:itunes_id => product_id,
                          :bought_at => email.date,
                          :text => text,
                          :message_id => email.message_id}
          end
        end

        itunes_products = find_products_on_itunes purchases.map{|p| p[:itunes_id]}

        purchases.map do |purchase|
          next unless product = itunes_products[purchase[:itunes_id]]

          purchase.merge!({
            :title => product.title,
            :source_url => product.page_url,
            :orig_image_url => product.large_image_url,
            :orig_thumb_url => product.large_image_url,
            :external_id => product.custom_product_id})
        end.compact
      end
    end


    class EtsyEmailParser
      
      def initialize(store)
      end
      
      def make_etsy_products_from_items(items)
        etsy_products = {}

        items.each do |id,item|
          etsy_products[id] = EtsyProduct.new item
        end

        etsy_products
      end

      def parse(emails)
        items = {}
        purchases = []

        emails.each do |email|
          text = email.body.to_s

          item_specs = text.scan(/www.etsy.com\/transaction\/(\d+).*\s+(.*)\s+\<\/a\>/)
          item_imgs  = text.scan(/www.etsy.com\/transaction\/(\d+).*\s+.*src=\"(.*)\"\s+/)

          item_specs.each do |item_spec| 
            item_id     = item_spec[0]
            item_title  = CGI.unescapeHTML(item_spec[1])

            items[item_id] = {:transaction_id => item_id,
                              :title => item_title}

            purchases << {:etsy_id => item_id,
                          :bought_at => email.date,
                          :text => text,
                          :message_id => email.message_id}
          end

          item_imgs.each do |item_img|
            items[item_img[0]][:image_url] = item_img[1] if items.key?(item_img[0])
          end
        end

        etsy_products = make_etsy_products_from_items(items)

        purchases.map do |purchase|
          product = etsy_products[purchase[:etsy_id]]

          purchase.merge!({
            :title => product.title,
            :source_url => product.page_url,
            :orig_image_url => product.large_image_url,
            :orig_thumb_url => product.medium_image_url,
            :external_id => product.custom_product_id})
        end.compact
      end
    end


    class ZapposEmailParser
      
      def initialize(store)
      end
      
      def find_products_on_zappos(product_ids,product_colors)
        products = {}

        product_ids.in_groups_of(10,false).each do |group|
          Zappos.lookup(group).each do |product|
            products[product.product_id] = product
          end
        end

        products
      end

      def parse(emails)
        purchases = []

        emails.each do |email|
          text = email.body.to_s

          product_specs = text.scan(/SKU#\s*(\d+)\sColor:\s*(.*)$/)

          product_specs.each do |product_spec|
            purchases << {:zappos_id => product_spec[0],
                          :color     => CGI.unescapeHTML(product_spec[1]),
                          :bought_at => email.date,
                          :text => text,
                          :message_id => email.message_id}
          end
        end

        zappos_products = find_products_on_zappos(
                            purchases.map{|p| p[:zappos_id]},
                            purchases.map{|p| p[:color]})

        purchases.map do |purchase|
          next unless product = zappos_products[purchase[:zappos_id]]

          purchase.merge!({
            :title => product.title,
            :source_url => product.page_url,
            :orig_image_url => product.large_image_url,
            :orig_thumb_url => product.medium_image_url,
            :external_id => product.custom_product_id})
        end.compact
      end
    end

  end #purchase email parsing

end #dw
