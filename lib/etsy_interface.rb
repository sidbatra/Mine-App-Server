module DW
  
  module EtsyInterface
    
    class EtsyProduct
      
      def initialize(item)
        @item = item
      end

      def is_image_present?
        @item[:image_url].present?
      end

      def medium_image_url
        is_image_present? ? @item[:image_url].gsub("75x75","170x135") : nil
      end

      def large_image_url
        is_image_present? ? @item[:image_url].gsub("75x75","570xN") : nil
      end

      def page_url
        "http://www.etsy.com/transaction/#{product_id}"
      end

      def product_id
        @item[:transaction_id]
      end

      def custom_product_id
        "ET-#{product_id}"
      end

      def title
        @item[:title]
      end

    end #etsy product
    
  end #etsy interface
end #dw
