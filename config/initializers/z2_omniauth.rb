
ActionController::Dispatcher.middleware.use OmniAuth::Builder do
  provider :google, 
    CONFIG[:google_client_id], 
    CONFIG[:google_client_secret],
    {:scope => "https://mail.google.com/"}
  provider :yahoo, CONFIG[:yahoo_consumer_key], CONFIG[:yahoo_consumer_secret]
end

OmniAuth.config.on_failure = Proc.new do |env|
  response = Rack::Response.new( 
              ["302 Moved"],
              302,
              'Location' => "/auth/#{env['omniauth.error.strategy'].name}"\
                            "/failure?#{env['rack.request.query_string']}&error=true")
  response.finish
  #OmniAuth::FailureEndpoint.new(env).redirect_to_failure 
end
