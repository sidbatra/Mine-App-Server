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
      @stores  = Store.top
      @options = {}
    when :all
      @stores  = Store.fetch_all
      @options = {:only => [:id,:name],:methods => []}
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end
  
end
