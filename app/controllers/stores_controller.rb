class StoresController < ApplicationController

  # Display a specific store. 
  #
  # This has been gutted for the time being and there isn't
  # a way for the user to arrive at this page. It's used as a
  # shell for OG tags.
  #
  def show
    @store  = Store.find_by_handle(params[:handle])
  end

  # List of stores conditional on a given aspect.
  #
  # params[:aspect] - Controls the bundle of stores to
  #                   to listed.
  # :all - An aspect of all returns all stores in the db.
  #
  def index
    @aspect = params[:aspect].to_sym

    case @aspect
    when :all
      all
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json do
        render @aspect
      end
    end
  end


  protected

  # Fetch all stores for the :all aspect on the index route
  #
  def all
    @key = "v1/stores/all"
    @stores = Store.select(:id,:name,:domain) unless fragment_exist? @key
  end
  
end
