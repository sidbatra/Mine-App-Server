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
        url = build_url(query,limit)
        url_only ? url.to_s : fetch_response(url)
      end


      protected

      # Construct the url for performing a web search
      #
      def self.build_url(query,limit,extras={})
        params = {
          'country' => "us",
          'entity' => "software",
          'media' => "software",
          'term' => "#{CGI.escape(query)}",
          'limit' => limit}

        extras.each{|k,v| params[k] = v}
        
        URI::HTTP.build([
          nil,"itunes.apple.com",
          nil,"/search",
          params.map{|k,v| "#{k}=#{v}"}.join('&'),nil])
      end

      # Fetch json response from the given url via the
      #  third party search api
      #
      def self.fetch_response(url)
        url.to_s
      end

    end #itunes search
    
  end #itunes interface
end #dw
