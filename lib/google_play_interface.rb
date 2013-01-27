module DW
  
  module GooglePlayInterface
    
    class GooglePlay 

      # Lookup google play apps with the given query 
      #
      # query - String 
      #
      def self.lookup(query)
       sq = MarketBot::Android::SearchQuery.new(query)
       sq.update

       sq.results.map{|result| GooglePlayProduct.new result}
      end

    end #google play search


    class GooglePlayProduct
      
      def initialize(item)
        @item = item
      end

      def large_image_url
        @item[:banner_icon_url].gsub('=w78-h78','')
      end

      def page_url
        @item[:market_url]
      end

      def product_id
        @item[:market_id] 
      end

      def custom_product_id
        "GP-#{product_id}"
      end

      def title
        @item[:title] 
      end
    end
    
  end #google play interface
end #dw
