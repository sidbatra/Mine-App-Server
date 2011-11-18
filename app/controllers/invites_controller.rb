# Handle requests for user invites
#
class InvitesController < ApplicationController
  before_filter :login_required, :only => [:index]

  # Fetch the user's facebook friends 
  #
  def index
    fb_user   = FbGraph::User.new(
                              'me', 
                              :access_token => self.current_user.access_token)          
    @friends  = fb_user.friends.sort{|x,y| x.name <=> y.name}
  rescue => ex
    handle_exception(ex)
  ensure
  end

end
