# Handle requests for the user resource
#
class UsersController < ApplicationController

  # Create a user based on token received from facebook
  #
  def create
    raise IOError, "User rejected FB connect" unless params[:code]

    fb_auth                   = FbGraph::Auth.new(
                                  CONFIG[:fb_app_id],
                                  CONFIG[:fb_app_secret])
    client                    = fb_auth.client
    client.redirect_uri       = fb_reply_url
    client.authorization_code = params[:code]
    access_token              = client.access_token!

    raise IOError, "Error fetching access token" unless access_token


    fb_user = FbGraph::User.fetch("me?fields=first_name,last_name,"\
                                  "gender,email,birthday",
                                    :access_token => access_token)
    @user = User.add(fb_user)

    raise IOError, "Error creating user" unless @user


    self.current_user = @user
    set_cookie
    target_url = new_product_path

  rescue => ex
    handle_exception(ex)
    target_url = root_path
  ensure
    redirect_to target_url
  end

end
