module DW

  # Set of classes and methods for performing web search
  #
  module WebSearchInterface
    
    # Perform web search and return results as objects of the
    # WebSearch class
    #
    class WebSearch
      attr_accessor :results

      # Web search constants
      #
      SOURCES = {:web => 'Web',:image => 'Image',:spell => 'SpellingSuggestions'}
      IMAGE_SIZES = { :small => 'Size:Small',
                      :medium => 'Size:Medium',
                      :large => 'Size:Large'}

      # Perform a web search on html pages i.e. a classic web search
      #
      # query - String. Bunch of words to be searched for on the web.
      # limit - Integer:1. Max number of results in the output.
      # offset - Integer:0. Page number of results. Minimum 0.
      # url_only - Boolean:false. Only return the url without running request.
      #
      # returns - WebSearch object.
      #
      def self.on_pages(query,limit=10,offset=0,url_only=false)
        url = build_url(query,:web,limit,offset,{})
        url_only ? url.to_s : fetch_response(url)
      end

      # Perform a web search on images
      #
      # query - String. Bunch of words for which images are to be found.
      # size - Symbol. Filter on size of images. :small,:medium,:large,:all
      # limit - Integer:1. Max number of results in the output.
      # offset - Integer:0. Page number of results. Minimum 0.
      # url_only - Boolean:false. Only return the url without running request.
      #
      # returns - WebSearch object.
      #
      def self.on_images(query,size,limit=10,offset=0,url_only=false)
        extras = size == :all ? 
                  {} : 
                  {'ImageFilters' => "'#{IMAGE_SIZES[size]}'"}

        url = build_url(query,:image,limit,offset,extras)
        url_only ? url.to_s : fetch_response(url)
      end

      # Use web search api for spelling correction
      #
      def self.for_spelling(query,url_only=false)
        url = build_url(query,:spell,1,0,{})
        url_only ? url.to_s : fetch_response(url)
      end


      protected

      # Construct the url for performing a web search
      #
      def self.build_url(query,source,limit,offset,extras={})
        params = {
          'Market' => "'en-US'",
          'Query' => "'#{CGI.escape(query)}'",
          '$format' => "Json",
          '$top' => limit,
          '$skip' => offset}

        extras.each{|k,v| params[k] = v}
        
        URI::HTTPS.build([
          nil,"api.datamarket.azure.com",
          nil,"/Data.ashx/Bing/Search/#{SOURCES[source]}",
          params.map{|k,v| "#{k}=#{v}"}.join('&'),nil])
      end

      # Fetch json response from the given url via the
      #  third party search api
      #
      def self.fetch_response(url)
        #http      = Net::HTTP.new(url.host,url.port)
        #request   = Net::HTTP::Get.new(url.request_uri)
        ##request.basic_auth "",CONFIG[:windows_azure_key]
        #response  = http.request(request)

        #body = ""
        #body = response.body if response.code == "200"

        #new(body)
        new(Typhoeus::Request.get(url.to_s,
              :username => "",
              :password => CONFIG[:windows_azure_key]).body)
      end


      # Create a class object from a params hash making all 
      # keys of the params hash available as instance variables
      #
      def initialize(body)
        @results = JSON.parse(body)["d"]["results"]
      end

    end #web search

  end #web search interface

end #dw
