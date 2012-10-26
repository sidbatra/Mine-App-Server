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
          AmazonProductSearch.lookup_products(group).each do |product|
            products[product.product_id] = product
          end
        end

        products
      end

      def search_products_on_amazon(product_names)
        products = {}

        product_names.in_groups_of(10,false).each do |group|
          hydra = Typhoeus::Hydra.new

          group.each do |product_name|
            request = Typhoeus::Request.new(
                        AmazonProductSearch.fetch_products("\"#{product_name}\"",1,true),
                        :connect_timeout => 1000,
                        :timeout => 3500)

            request.on_complete do |response| 
              begin
                item = Amazon::Ecs::Response.new(response.body).items.first

                if item
                  product = AmazonProduct.new(item)
                  products[product_name] = product
                end
              rescue => ex
              end
            end 

            hydra.queue request
          end #group

          hydra.run
        end #groups

        products
      end

      def initial_purchase_hash(key,text,email)
        {:asn_key => key,
          :bought_at => email.date,
          :text => text,
          :message_id => email.message_id}
      end

      def parse_digital_email(email)
        purchases = []
        text = email.html_part.to_s
        product_ids = text.
                        scan(/www.amazon.com\/gp\/product\/([\w]+)/).
                        flatten.
                        uniq
        product_ids.each do |product_id|
          purchases << initial_purchase_hash(product_id,text,email)
        end

        purchases
      end

      def parse_offline_email(email)
        purchases = []
        text = email.html_part.to_s
        product_names = text.
                          scan(/<b>"([^"]+)"<\/b>/).
                          flatten.
                          uniq

        product_names.each do |product_name|
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

        purchase_keys = purchases.map{|p| p[:asn_key]}

        amazon_products = @is_digital ? 
                            find_products_on_amazon(purchase_keys) :
                            search_products_on_amazon(purchase_keys)

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
          text = email.html_part.to_s
          product_ids = text.
                          scan(/addUserReview?[^(]+&id=3D([\d]+)/).
                          flatten.
                          uniq.
                          map(&:to_s)
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

  end #purchase email parsing

end #dw
