# Handle requests for user invites
#
class InvitesController < ApplicationController
  before_filter :login_required, :only => [:create]

end
