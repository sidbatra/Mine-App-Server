module DW

  module PurchaseEmailParsing
    
    class PurchaseEmailParser
      def initialize(store)
        @store = store
        @parser = Object.const_get("#{store.name.capitalize}EmailParser").send :new 
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
      
      def find_products_on_amazon(product_ids)
        products = {}

        product_ids.in_groups_of(10,false).each do |group|
          AmazonProductSearch.lookup_products(group).each do |product|
            products[product.product_id] = product
          end
        end

        products
      end

      def parse(emails)
        purchases = []

        emails.each do |email|
          product_ids = email.html_part.to_s.
                          scan(/www.amazon.com\/dp\/([^r]+)\/ref/).
                          flatten.
                          uniq
          product_ids.each do |product_id|
            purchases << {:asn_id => product_id,
                          :bought_at => email.date,
                          :text => email.html_part.to_s,
                          :uid => email[:uid]}
          end
        end

        amazon_products = find_products_on_amazon purchases.map{|p| p[:asn_id]}

        purchases.map do |purchase|
          next unless product = amazon_products[purchase[:asn_id]]

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
