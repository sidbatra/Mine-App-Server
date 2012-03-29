class ApplicationController < ActionController::Base
  helper :all 
  protect_from_forgery 
  filter_parameter_logging :password, :secret 
  before_filter :track_source


  include ExceptionLoggable, DW::AuthenticationSystem, DW::RequestManagement

  protected

  # Populate the source variable for analytics before
  # every request
  #
  def track_source
    @source = params[:src] ? params[:src].to_s : 'direct'
  end

  # Renew an active session after a certain time period to mark
  # the user as an active user on the site
  #
  def renew_session
    if logged_in? && (!session[:last_renewed_at] || 
                    Time.now - session[:last_renewed_at] > 86400)
      
      self.current_user.touch
      session[:last_renewed_at] = Time.now
    end
  end

  # Prepare parameters for the image uploder
  #
  def generate_uploader
    u = {}
    u[:server]     = "http://#{CONFIG[:s3_bucket]}.s3.amazonaws.com/"
    u[:aws_id]     = CONFIG[:aws_access_id]
    u[:max]        = 50.megabytes
    u[:extensions] = "*.jpeg;*.jpg;*.gif;*.bmp;*.png"
    u[:key]        = Base64.encode64(
                       SecureRandom.hex(10) + 
                       Time.now.to_i.to_s).chomp 
    u[:policy]     = Base64.encode64(
                              "{'expiration': '#{6.year.from_now.
                                  utc.strftime('%Y-%m-%dT%H:%M:%S.000Z')}',
                                'conditions': [
                                  {'bucket': '#{CONFIG[:s3_bucket]}'},
                                  {'acl': 'public-read'},
                                  {'success_action_status': '201'},
                                  ['content-length-range',0, #{u[:max]}],
                                  ['starts-with', '$key', '#{u[:key]}'],
                                  ['starts-with', '$Filename', '']
                                ]
                              }").gsub(/\n|\r/, '')
    u[:signature]   = Base64.encode64(
                              OpenSSL::HMAC.digest(
                                OpenSSL::Digest::Digest.new('sha1'),
                                CONFIG[:aws_secret_key],
                                u[:policy])).gsub("\n","")
    @upload_config = u
  end

end

