# Handle requests for the searches resource
#
class SearchesController < ApplicationController
  before_filter :login_required,  :only => [:create]

  # Create a new comment
  #
  def create
    @search = Search.add(
                        params[:search],
                        self.current_user.id)
  rescue => ex
    handle_exception(ex)
  ensure
  end
end
