module DW

  module Tagging
    
    class ProductTagger

      def initialize(url,unique_id)
        @url = url || ""
        @unique_id = unique_id || ""
      end
      
      def tags
        tags = nil
        
        if from_amazon?
          tags = amazon_tags
        end

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      ensure
        return tags
      end


      private

      def from_amazon?
        @unique_id =~ /^AZ-/ || @url =~ /www\.amazon\./
      end

      def amazon_id
        asn = nil

        asn = @unique_id[3..-1] if @unique_id.present?
        asn ||= @url.scan(/dp\/(\w+)/).flatten.first 
        asn ||= @url.scan(/gp\/product\/(\w+)/).flatten.first

        asn
      end

      def amazon_tags
        tags = nil
        asn = amazon_id

        product = AmazonProductSearch.lookup_products(asn).first if asn
        tags = product.tags if product

        tags
      end

    end #product tagger


  end #tagging
end #dw
