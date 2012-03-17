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

      # Perform a web search on html pages i.e. a classic web search
      #
      def self.on_pages(query,limit=10,offset=0)
        fetch_response build_url(query,[:web],{:web => limit},{:web => offset})
      end


      protected

      # Construct the url for performing a web search
      #
      def self.build_url(query,sources,limits,offsets)
        params = {
          'AppId'   => CONFIG[:bing_app_id],
          'Version' => '2.2', 
          'Market'  => 'en-US',
          'Query'   => CGI.escape(query),
          'Sources' => sources.map{|s| SOURCES[s]}.join('+')}

        limits.each{|k,v| params[LIMITS[k]] = v}
        offsets.each{|k,v| params[OFFSETS[k]] = v}
        
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

        new(JSON.parse(body)["SearchResponse"])
      end


      # Create a class object from a params hash making all 
      # keys of the params hash available as instance variables
      #
      def initialize(params)
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
