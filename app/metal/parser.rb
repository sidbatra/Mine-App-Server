# Parse image urls and title of the page from the given url

class Parser
  def self.call(env)

    if env["PATH_INFO"] =~ /^\/parser/
      require 'rubygems'
      require 'mechanize'

      images  = []
      title   = ""

      begin
        request = Rack::Request.new(env)
        params  = request.params
        source_url = params['source']
        
        agent = Mechanize.new
        agent.user_agent_alias = 'Mac Safari'
        agent.get(source_url)

        if agent.page.is_a? Mechanize::Page
          base_uri = URI.parse(URI.encode(source_url))
          
          images = agent.page.images.map do |img| 
                    begin
                      img.src.match(/^http/) ? 
                        img.src : 
                        URI.decode(base_uri.merge(URI.encode(img.src)).to_s).
                             gsub("¥","\\")
                    rescue
                      img.src ? img.src : ''
                    end
                   end

          title = agent.page.title
        else
          images = [source_url]
        end
      rescue
      end

      result = {:images => images,:title => title,:source => source_url}
      [200, {"Content-Type" => "application/json"}, [result.to_json]]
    else
      [404, {"Content-Type" => "text/html"}, [].to_json]
    end
  end
end
