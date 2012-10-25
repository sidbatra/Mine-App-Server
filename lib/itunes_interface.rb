module DW
  
  module ItunesInterface
    
    class Itunes

      # Perform an app search.
      #
      # query - The String query for the search.
      # limit - The Integer max results per page.
      # url_only - Boolean:false. Only return the url without running request.
      #
      # returns - The String URL for running an app search.
      #
      def self.search_apps(query,limit=10,url_only=true)
        params = {
          'country' => "us",
          'entity' => "software",
          'media' => "software",
          'term' => "#{CGI.escape(query)}",
          'limit' => limit}
          
        url = build_url("/search",params)
        url_only ? url.to_s : fetch_response(url)
      end

      # Lookup itunes entities with the given ids.
      #
      # ids - CSV String or Array of entity ids
      # url_only - Return url or full set of results.
      #
      def self.lookup(ids,url_only=false)
        ids = ids.join(",") if ids.is_a? Array

        params = {
          'id' => ids}

        url = build_url("/lookup",params)
        url_only ? url.to_s : fetch_response(url)
      end


      protected

      def self.build_url(route,params)
        URI::HTTP.build([
          nil,"itunes.apple.com",
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
          products = JSON.parse(response)["results"].map do |result| 
                      ItunesProduct.new result
                     end
        end
        
        products
      end

    end #itunes search


    class ItunesProduct
      
      def initialize(item)
        @item = item
      end

      def small_image_url
        @item["artworkUrl60"]
      end

      def large_image_url
        @item["artworkUrl512"]
      end

      def page_url
        @item["trackViewUrl"]
      end

      def product_id
        @item["trackId"].to_s
      end

      def custom_product_id
        "AP-#{product_id}"
      end

      def title
        @item["trackName"]
      end
    end
    
  end #itunes interface
end #dw
