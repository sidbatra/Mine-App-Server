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
      SOURCES = {:web => 'Web',:image => 'Image'}
      LIMITS  = {:web => 'Web.Count',:image => 'Image.Count'}

      # Construct the url for performing a web search
      #
      def self.url(query,sources,limits)
        params = {
          'AppId'   => CONFIG[:bing_app_id],
          'Version' => '2.2', 
          'Market'  => 'en-US',
          'Query'   => query,
          'Sources' => sources.map{|s| SOURCES[s]}.join('+')}

        limits.each{|k,v| params[LIMITS[k]] = v}
        
        URI::HTTP.build([
              nil,'api.bing.net',nil,'/json.aspx',
              params.map{|k,v| "#{k}=#{v}"}.join('&'),nil])
      end

    end #web search

  end #web search interface

end #dw
