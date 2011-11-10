# Handle store related request for admin view
#
class Admin::StoresController < ApplicationController
  before_filter :admin_required 

  # Show all stores pending approval with editing options 
  #
  def index
    @approved_stores    = Store.approved
    @unapproved_stores  = Store.unapproved.sorted
  end


  # Update the store name. If the updated name is already in the
  # database, then delete the store and move all its products to
  # the existing store
  #
  def update
    store           = Store.find(params[:id])
    fetched_store   = Store.fetch(params[:name])
    
    if fetched_store.nil? || store.id == fetched_store.id
      params[:is_approved] = true
      store.edit(params)

      @store = store
    else
      store.move_products_to(fetched_store)
      store.destroy

      @store = fetched_store
    end
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

  # Show all products from a store
  #
  def show
    @store = Store.find(params[:id])
  end

end
