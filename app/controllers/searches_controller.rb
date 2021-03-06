class SearchesController < ApplicationController
  before_filter :login_required

  # Create a new search.
  #
  def create
    @search = Search.add(params,self.current_user.id)
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end
end
