module DW

  module Tagging


    class ProductTagger

      def initialize(url,unique_id)
        @tagger = nil
        @tagger ||= AmazonProductTagger.matches? url,unique_id
      end

      def available?
        @tagger.present?
      end

      # Extend the method_missing method to enable product tagger
      # to act as a shell for product tagger classes.
      #
      def method_missing(method,*args,&block)

        if available? && @tagger.respond_to?(method)
          #begin
            @tagger.send method,*args,&block
          #rescue => ex
          #  LoggedException.add(__FILE__,__method__,ex)
          #end
        else
          super
        end
      end

    end #product tagger

    

    class AmazonProductTagger

      def self.matches?(url,unique_id)
        matches = unique_id =~ /^AZ-/ || url =~ /www\.amazon\./ 
        matches ? self.new(url,unique_id) : nil
      end


      def initialize(url,unique_id)
        @url = url || ""
        @unique_id = unique_id || ""
      end
      
      def tags
        tags = nil
        asn = external_id

        product = AmazonProductSearch.lookup_products(asn).first if asn
        tags = product.tags if product

        tags
      end

      def external_id
        asn = nil

        asn = @unique_id[3..-1] if @unique_id.present?
        asn ||= @url.scan(/dp\/(\w+)/).flatten.first 
        asn ||= @url.scan(/gp\/product\/(\w+)/).flatten.first

        asn
      end

      def symbol
        :amazon
      end
    end


  end #tagging
end #dw
