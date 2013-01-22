module DW

  module Tagging

    class BulkProductTagger

      def initialize(products)
        @products = products
        @mapper = {}
      end

      def tag
        @products.each do |product|
          next if product.tags.present?

          tagger = ProductTagger.new product.source_url,product.external_id
          next unless tagger.available?
          
          external_id = tagger.external_id
          next unless external_id

          symbol = tagger.symbol
          @mapper[symbol] = {} unless @mapper.include?(symbol)

          @mapper[symbol][external_id] = [] unless @mapper[symbol].include?(external_id)
          @mapper[symbol][external_id] << product
        end

        tag_amazon_products if @mapper[:amazon].present?
        tag_itunes_products if @mapper[:itunes].present?
        tag_bestbuy_products if @mapper[:bestbuy].present?
      end

      def tag_amazon_products
        @mapper[:amazon].keys.in_groups_of(10,false).each do |group|
          AmazonProductSearch.lookup_products(group).each do |item|

            @mapper[:amazon][item.product_id].each do |product|
              product.tags = item.tags
              product.save!
            end #products

          end #groups
        end #keys
      end

      def tag_itunes_products
        @mapper[:itunes].keys.in_groups_of(10,false).each do |group|
          Itunes.lookup(group).each do |item|

            @mapper[:itunes][item.product_id].each do |product|
              product.tags = item.tags
              product.save!
            end #products

          end #groups
        end #keys
      end

      def tag_bestbuy_products
        @mapper[:bestbuy].keys.in_groups_of(10,false).each do |group|
          BestBuy.lookup(group).each do |item|

            @mapper[:bestbuy][item.product_id].each do |product|
              product.tags = item.tags
              product.save!
            end #products

          end #groups
        end #keys
      end

    end #bulk product tagger



    class ProductTagger

      def initialize(url,unique_id)
        @tagger = nil
        @tagger ||= AmazonProductTagger.matches? url,unique_id
        @tagger ||= ITunesProductTagger.matches? url,unique_id
        @tagger ||= BestBuyProductTagger.matches? url,unique_id
        @tagger ||= EbayProductTagger.matches? url,unique_id
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



    class ITunesProductTagger

      def self.matches?(url,unique_id)
        matches = unique_id =~ /^AP-/ || url =~ /itunes\.com/ 
        matches ? self.new(url,unique_id) : nil
      end


      def initialize(url,unique_id)
        @url = url || ""
        @unique_id = unique_id || ""
      end
      
      def tags
        tags = nil
        id = external_id

        product = Itunes.lookup(id).first if id
        tags = product.tags if product

        tags
      end

      def external_id
        id = nil

        id = @unique_id[3..-1] if @unique_id.present?
        id ||= @url.scan(/id(\w+)/).flatten.first 

        id
      end

      def symbol
        :itunes
      end
    end


    class BestBuyProductTagger

      def self.matches?(url,unique_id)
        matches = unique_id =~ /^BB-/ || url =~ /bestbuy\.com/ 
        matches ? self.new(url,unique_id) : nil
      end


      def initialize(url,unique_id)
        @url = url || ""
        @unique_id = unique_id || ""
      end
      
      def tags
        tags = nil
        sku = external_id

        product = BestBuy.lookup(sku).first if sku
        tags = product.tags if product

        tags
      end

      def external_id
        sku = nil

        sku = @unique_id[3..-1] if @unique_id.present?
        sku ||= @url.scan(/\/(\w+)\.p/).flatten.first 
        sku ||= @url.scan(/skuId=(\w+)/).flatten.first

        sku
      end

      def symbol
        :bestbuy
      end
    end



    class EbayProductTagger

      def self.matches?(url,unique_id)
        matches = unique_id =~ /^EB-/ || url =~ /ebay\.com/ 
        matches ? self.new(url,unique_id) : nil
      end


      def initialize(url,unique_id)
        @url = url || ""
        @unique_id = unique_id || ""
      end
      
      def tags
        tags = nil
        id = external_id

        product = Ebay.lookup(id).first if id
        tags = product.tags if product

        tags
      end

      def external_id
        id = nil

        id = @unique_id[3..-1] if @unique_id.present?
        id ||= @url.scan(/\/(\d+)/).flatten.first 

        id
      end

      def symbol
        :ebay
      end
    end

  end #tagging
end #dw
