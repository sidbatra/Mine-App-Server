# Handle requests for the store resource
#
class StoresController < ApplicationController
  before_filter :renew_session, :only => :show

  # Display a store
  #
  def show
    @store  = Store.find_by_handle(params[:handle])
  end

  # Fetch list of stores
  #
  def index
    @filter = params[:filter].to_sym

    case @filter
    when :top
      @stores   = Store.select(:id,:name,:handle,:is_processed,:image_path).
                        processed.
                        popular.
                        limit(20)
      @key      = KEYS[:store_top]
    when :suggest
      @stores   = Store.select(:id,:name,:handle,:is_processed,:image_path).
                        processed.
                        popular.
                        limit(60)
      @key      = KEYS[:store_suggest]
    when :all
      @stores   = Store.select(:id,:name)
      @key      = KEYS[:store_all]
    when :for_user
      @stores   = Store.select('stores.id',:name,:handle,:is_processed,
                                :image_path).
                        processed.
                        for_user(params[:user_id]).
                        limit(10)
      @key      = KEYS[:user_top_stores] % params[:user_id]
    when :related
      @category_id  = Specialty.top_category_id_for_store(params[:store_id])
      @stores       = Store.select('stores.id',:name,:handle,:is_processed,
                                    :image_path).
                            processed.
                            for_specialty(@category_id).
                            limit(11)
      @key          = KEYS[:store_related_in_category] % @category_id
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end
  
end
