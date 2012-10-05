class TwitterController < ApplicationController
  before_filter :create_client

  # Start the twitter authentication process.
  #
  def new
    @target_url = root_path(:src => HomeShowSource::LoginError)

    callback_url = tw_reply_url(
                    :src    => @source,
                    :target => params[:target],
                    :follow_user_id => params[:follow_user_id],
                    :usage  => params[:usage])

    request_token = @client.authentication_request_token(:oauth_callback => callback_url)
    session[:tw_request_token] = request_token

    @target_url = request_token.authorize_url

  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to @target_url
  end

  # Handle replies from twitter oauth.
  #
  def create
    @usage = params[:usage] ? params[:usage].to_sym : :redirect
    oauth_verifier = params[:oauth_verifier]

    if oauth_verifier
      access_token = @client.authorize(
                              session[:tw_request_token].token,
                              session[:tw_request_token].secret,
                              :oauth_verifier => oauth_verifier)  

      case @usage
      when :redirect
        @target_url = create_user_path(
                        :using => "twitter",
                        :tw_access_token => access_token.token,
                        :tw_access_token_secret => access_token.secret,
                        :target => params[:target],
                        :src => @source,
                        :follow_user_id => params[:follow_user_id])

      when :popup
        self.current_user.tw_access_token = access_token.token
        self.current_user.tw_access_token_secret = access_token.secret
        self.current_user.tw_user_id = access_token.params['user_id']

        self.current_user.save!
      end
    else
      @error = true
    end

  rescue => ex
    handle_exception(ex)
  ensure
    case @usage
    when :redirect
      redirect_to @error ? root_path(:src => HomeShowSource::TWDenied) : @target_url
    end
  end


  private

  # Create a twitter client variable.
  #
  def create_client
    @client = TwitterOAuth::Client.new(
                :consumer_key     => CONFIG[:tw_consumer_key], 
                :consumer_secret  => CONFIG[:tw_consumer_secret]) 
  end

end
