# Handle requests for the collections resource
#
class CollectionsController < ApplicationController
  before_filter :login_required, :except => [:index,:show]

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
                    params[:collection][:name],
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
                        :src    => UserShowSource::CollectionCreate,
                        :anchor => UserShowHash::Collections)
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
                        with_user.
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

  # Display a collection 
  #
  def show
    user        = User.find_by_handle(params[:user_handle])
    @collection = Collection.with_products.find_by_id_and_user_id(
                                              params[:id],
                                              user.id)

  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to root_path if @error
  end

  # Update a collection 
  #
  def update
    @collection = Collection.find_by_id(params[:id])

    if @collection.user_id == self.current_user.id
      @collection.update_attributes(params[:collection])
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
