class ApplicationController < ActionController::Base
  helper :all 
  protect_from_forgery 
  filter_parameter_logging :password, :secret 
  before_filter :track_source

  include ExceptionLoggable, DW::AuthenticationSystem, DW::RequestManagement

  protected

  # Populate the @source variable before every request using the :src param.
  # if :src isn't present set @source to 'direct'.
  #
  def track_source
    @source = params[:src] ? params[:src].to_s : 'direct'
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

end

