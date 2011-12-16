# Handle requests for the collections resource
#
class CollectionsController < ApplicationController
  before_filter :login_required,  :only => [:create]

  # Create a new collection
  #
  def create
    @collection = Collection.add(params[:product_ids],self.current_user.id)
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

end
