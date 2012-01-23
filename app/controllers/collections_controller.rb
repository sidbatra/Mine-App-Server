# Handle requests for the collections resource
#
class CollectionsController < ApplicationController
  before_filter :login_required, :except => :index

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
                        :src => CollectionNewSource::Error) :
                      user_path(
                        self.current_user.handle,
                        :src => UserShowSource::CollectionCreate)
      end
      format.json 
    end
  end

  # Fetch list of collections
  #
  def index
    @filter   = params[:filter].to_sym
    @options  = {}

    case @filter
    when :user_last
      @collections  = Collection.for_user(params[:owner_id]).
                        last
      @key          = KEYS[:collection_products] % 
                        (@collections ? @collections.id : 0)
    when :user
      @collections  = Collection.for_user(params[:owner_id]).
                        with_products.
                        by_id
      @key          = KEYS[:user_collections] % params[:owner_id]
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
