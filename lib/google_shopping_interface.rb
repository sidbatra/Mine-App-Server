module DW

  module GoogleShoppingInterface
    
    class GoogleShopping

      # Perform a product search.
      #
      # query - The String query for the search.
      # limit - The Integer max results per page.
      # page - The Integer page number of results.
      # url_only - Boolean:false. Only return the url without running request.
      #
      # returns - The String URL for running a product search.
      #
      def self.search_products(query,limit=10,page=1,url_only=true)
        url = build_url(query,limit,page)
        url_only ? url.to_s : fetch_response(url)
      end


      protected

      # Construct the url for performing a web search
      #
      def self.build_url(query,limit,page,extras={})
        params = {
          'country' => "US",
          'key' => CONFIG[:google_api_key],
          'q' => "#{CGI.escape(query)}",
          'thumbnails' => "180:*",
          'maxResults' => limit,
          'startIndex' => (page-1)*limit + 1}

        extras.each{|k,v| params[k] = v}
        
        URI::HTTPS.build([
          nil,"www.googleapis.com",
          nil,"/shopping/search/v1/public/products",
          params.map{|k,v| "#{k}=#{v}"}.join('&'),nil])
      end

      # Fetch json response from the given url via the
      #  third party search api
      #
      def self.fetch_response(url)
        url.to_s
      end

    end #google shopping

  end #google shopping interface

end #dw

