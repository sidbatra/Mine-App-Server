# Allow the metal piece to run in isolation
#require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

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
        
        agent = Mechanize.new
        agent.user_agent_alias = 'Mac Safari'
        agent.get(params['url'])

        uri = URI.parse(params['url'])
        
        images = agent.page.images.map do |img| 
                  begin
                    image_uri = URI.parse(img.src)
                    image_uri.host ? 
                      img.src : 
                      uri.scheme + "://" + uri.host + img.src
                  rescue
                    img.src
                  end
                 end

        title = agent.page.title
      rescue
      end

      result = {:images => images,:title => title}
      [200, {"Content-Type" => "application/json"}, [result.to_json]]
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end
end
