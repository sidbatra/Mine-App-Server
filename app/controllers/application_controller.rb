class ApplicationController < ActionController::Base
  helper :all 
  protect_from_forgery 
  filter_parameter_logging :password, :secret 
  before_filter :track_global_params

  include ExceptionLoggable, DW::AuthenticationSystem, DW::RequestManagement

  protected

  # Track params to of possible interest to all routes.
  #
  def track_global_params
    @source = params[:src] ? params[:src].to_s : 'direct'
    @web_view_mode = params[:web_view_mode]
  end

  # Mark current user as visited once every so often.
  #
  def track_visit
    if logged_in? && 
        (session[:visited_at].nil? || session[:visited_at] < 30.minutes.ago)
      self.current_user.visited
      session[:visited_at] = Time.now
      session[:renewed] = true
    else
      session[:renewed] = false    
    end
  end

  # Prepare uploader config for uploading directly to Amazon S3. Store
  # the config as a hash into @upload_config.
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

  # Populate theme variable.
  #
  def populate_theme(user)
    @theme = user.setting.theme
  end

  def mine_purchase_emails
    ProcessingQueue.push(PurchaseExtractor.new,
                          :mine_emails_for_user,
                          self.current_user) if params[:mode] == "live"
  end

  # Raise a routing exception when a non-existant resource
  # is accessed.
  #
  def raise_not_found
    raise ActionController::RoutingError.new('Not Found') 
  end

end

