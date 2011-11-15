# Handle requests for the store resource
#
class StoresController < ApplicationController
  before_filter :logged_in?,    :only => :show

  # Display a store
  #
  def show
    @store  = Store.find_by_handle(params[:handle])
  end
  
end
