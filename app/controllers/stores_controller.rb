# Handle requests for the store resource
#
class StoresController < ApplicationController
  before_filter :logged_in?,    :only => :show

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
      @stores   = Store.processed.popular.limit(20)
      @options  = {:only => [:handle],:methods => [:thumbnail_url]}
      @key      = KEYS[:store_top]
    when :suggest
      @stores   = Store.processed.popular.limit(35)
      @options  = {:only => [:handle],:methods => [:large_url]}
      @key      = KEYS[:store_suggest]
    when :all
      @stores   = Store.unfiltered
      @options  = {:only => [:id,:name]}
      @key      = KEYS[:store_all]
    when :for_user
      @stores   = Store.processed.for_user(params[:user_id])
      @options  = {:only => [:handle],:methods => [:thumbnail_url]}
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
