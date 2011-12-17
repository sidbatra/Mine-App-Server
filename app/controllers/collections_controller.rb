# Handle requests for the collections resource
#
class CollectionsController < ApplicationController
  before_filter :login_required

  # Display UI for creating a new collection
  #
  def new
    @collection = Collection.new
  rescue => ex
    handle_exception(ex)
  ensure
  end

  # Create a new collection
  #
  def create
    product_ids = params[:collection][:product_ids].split(',')

    @collection = Collection.add(
                    product_ids,
                    self.current_user.id)
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.html do
        redirect_to  @error ? 
                      new_collection_path(
                        :src => 'error') :
                      user_path(
                        self.current_user.handle,
                        :src => 'collection_create')
      end
      format.json 
    end
  end

end
