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
    when :all
      @stores   = Store.select(:id,:name,:domain)
      @key      = KEYS[:store_all]
    when :for_user
      @stores   = Store.select('stores.id',:name,:handle,:is_processed,
                                :image_path).
                        processed.
                        for_user(params[:user_id])
      @key      = KEYS[:user_top_stores] % params[:user_id]
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end
  
end
