module DW

  module BestBuyInterface

    class BestBuy

      def self.lookup(skus,url_only=false)
        skus = skus.join(",") if skus.is_a? Array

        params = {}

        url = build_url("/v1/products(sku%20in(#{skus}))",params)
        url_only ? url.to_s : fetch_response(url)
      end

      protected

      def self.build_url(route,params)
        params["format"] = "json"
        params["apiKey"] = CONFIG[:best_buy_api_key]
        params["show"] = "name,sku,url,largeImage,mediumImage,subclass,categoryPath"

        URI::HTTP.build([
          nil,"api.remix.bestbuy.com",
          nil,route,
          params.map{|k,v| "#{k}=#{v}"}.join('&'),nil])
      end

      # Fetch json response from the given url via the
      #  third party search api
      #
      def self.fetch_response(url)
        products = []
        response = Typhoeus::Request.get(url.to_s).body

        if response.present?
          output = JSON.parse(response)["products"]
          products = output.map do |product| 
                      BestBuyProduct.new product
                     end if output.present?
        end
        
        products
      end
    end #best buy


    class BestBuyProduct

      def initialize(item)
        @item = item
      end

      def medium_image_url
        @item["largeImage"]
      end

      def large_image_url
        @item["largeImage"].gsub("b.jpg","a.jpg") if @item["largeImage"]
      end

      def page_url
        @item["url"]
      end

      def product_id
        @item["sku"].to_s
      end

      def custom_product_id
        "BB-#{product_id}"
      end

      def title
        @item["name"]
      end

      def subclass
        subclass = @item["subclass"] 
        subclass ? CGI.unescapeHTML(subclass.downcase) : nil
      end

      def tags
        tags = []
        
        tags << subclass

        categories = @item["categoryPath"]

        categories[1..-1].each do |category|
          tags << CGI.unescapeHTML(category["name"].downcase)
        end if categories.present?

        tags.compact
      end
    end #best buy product

  end #best buy interface

end #dw
