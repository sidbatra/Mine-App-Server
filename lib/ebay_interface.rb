module DW
  
  module EbayInterface
    
    class Ebay 

      # Lookup ebay listings with the given ids.
      #
      # ids - CSV String or Array of entity ids
      # url_only - Return url or full set of results.
      #
      def self.lookup(ids,url_only=false)
        ids = ids.join(",") if ids.is_a? Array

        params = {
          'ItemID'            => ids,
          'version'           => 525,
          'siteid'            => 0,
          'appid'             => 'DenwenIn-b8b4-423a-b782-bee8f3077c80',
          'responseencoding'  => 'JSON', 
          'callname'          => 'GetMultipleItems'
          }

        url = build_url("/shopping",params)
        url_only ? url.to_s : fetch_response(url)
      end


      protected

      def self.build_url(route,params)
        URI::HTTP.build([
          nil,"open.api.ebay.com",
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
          products = JSON.parse(response)["Item"].map do |item| 
                      EbayProduct.new item 
                     end
        end
        
        products
      end

    end #ebay search


    class EbayProduct
      
      def initialize(item)
        @item = item
      end

      def medium_image_url
        @item["PictureURL"].present? ? @item["PictureURL"].first : nil
      end

      def large_image_url
        if medium_image_url.present?
          medium_image_url.include?("_1.JPG") ? medium_image_url.gsub("_1.JPG","_3.JPG") : medium_image_url
        else
          nil
        end
      end

      def page_url
        @item["ViewItemURLForNaturalSearch"] 
      end

      def product_id
        @item["ItemID"] 
      end

      def custom_product_id
        "EB-#{product_id}"
      end

      def title
        @item["Title"] 
      end

      def tags
        tags = []

        categories = @item["PrimaryCategoryName"]
        tags = categories.split(":").map(&:downcase) if categories

        tags
      end
    end
    
  end #ebay interface
end #dw
