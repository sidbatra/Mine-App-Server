module DW
  
  module ZapposInterface
    
    class Zappos 

      # Lookup zappos products with the given ids.
      #
      # ids - Array of entity ids
      # url_only - Return url or full set of results.
      #
      def self.lookup(ids,url_only=false)
        ids = "[%22" + ids.join(CGI.escape("\",\"")) + "%22]"

        params = {
          'id' => ids,
          'key'=> '2d0d97889624d073f8acb868f09381c8adabf454'}

        url = build_url("/Product",params)
        url_only ? url.to_s : fetch_response(url)
      end


      protected

      def self.build_url(route,params)
        URI::HTTP.build([
          nil,"api.zappos.com",
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
          products = JSON.parse(response)["product"].map do |product|
                      ZapposProduct.new product
                     end
        end
        
        products
      end

    end #zappos search


    class ZapposProduct
      
      def initialize(item)
        @item = item
        @medium_url = nil
      end

      def medium_image_url
        @medium_url ||= @item["defaultImageUrl"]
      end

      def large_image_url
        medium_image_url.include?("DETAILED") ? medium_image_url.gsub("DETAILED","2x") : medium_image_url 
      end

      def page_url
        @item["defaultProductUrl"] 
      end

      def product_id
        @item["productId"] 
      end

      def custom_product_id
        "ZA-#{product_id}"
      end

      def title
        @item["productName"]
      end
    end
    
  end #itunes interface
end #dw
