module DW

  # Set of classes and methods for performing web search
  #
  module WebSearchInterface
    
    # Perform web search and return results as objects of the
    # WebSearch class
    #
    class WebSearch

      # Web search constants
      #
      SOURCES = {:web => 'Web',:image => 'Image',:spell => 'Spell'}
      LIMITS  = {:web => 'Web.Count',:image => 'Image.Count'}
      OFFSETS = {:web => 'Web.Offset',:image => 'Image.Offset'}
      IMAGE_SIZES = {
                      :small => 'Size:Small',
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
        url = build_url(query,[:web],{:web => limit},{:web => offset})
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
        extras = size == :all ? {} : {'Image.Filters' => IMAGE_SIZES[size]}
        url = build_url(
                query,[:image],
                {:image => limit},
                {:image => offset},
                extras)
        url_only ? url.to_s : fetch_response(url)
      end


      protected

      # Construct the url for performing a web search
      #
      def self.build_url(query,sources,limits,offsets,extras={})
        params = {
          'AppId'   => CONFIG[:bing_app_id],
          'Version' => '2.2', 
          'Market'  => 'en-US',
          'Query'   => CGI.escape(query),
          'Sources' => sources.map{|s| SOURCES[s]}.join('+')}

        limits.each{|k,v| params[LIMITS[k]] = v}
        offsets.each{|k,v| params[OFFSETS[k]] = v}
        extras.each{|k,v| params[k] = v}
        
        URI::HTTP.build([
              nil,'api.bing.net',nil,'/json.aspx',
              params.map{|k,v| "#{k}=#{v}"}.join('&'),nil])
      end

      # Fetch json response from the given url via the
      #  third party search api
      #
      def self.fetch_response(url)
        http      = Net::HTTP.new(url.host,url.port)
        response  = http.request(Net::HTTP::Get.new(url.request_uri))

        body = ""
        body = response.body if response.code == "200"

        new(body)
      end


      # Create a class object from a params hash making all 
      # keys of the params hash available as instance variables
      #
      def initialize(body)
        params = JSON.parse(body)["SearchResponse"]
        params.each do |k,v|
          self.instance_variable_set("@#{k}",v)
          self.class.send(
            :define_method,
            k,
            proc{self.instance_variable_get("@#{k}")})
        end
      end

    end #web search

  end #web search interface

end #dw
