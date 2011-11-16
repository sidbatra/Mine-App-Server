# Handle requests for the store resource
#
class StoresController < ApplicationController
  before_filter :logged_in?,    :only => :show

  # Display a store
  #
  def show
    @source = params[:src] ? params[:src].to_s : "direct"
    @store  = Store.find_by_handle(params[:handle])
  end

  # Fetch list of stores
  #
  def index
    @filter = params[:filter].to_sym

    case @filter
    when :top
      @stores  = Store.top
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end
  
end
