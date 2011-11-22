# Handle store related request for admin view
#
class Admin::StoresController < ApplicationController
  before_filter :admin_required 

  # Fetch group of stores based on different filters 
  #
  def index
    @filter = params[:filter].to_sym

    case @filter
    when :unapproved
      @approved_stores  = Store.approved
      @stores           = Store.unapproved.sorted
    when :popular
      @stores           = Store.popular  
    end
  end


  # Update the store name. If the updated name is already in the
  # database, then delete the store and move all its products to
  # the existing store. Also handle cases for unknowns and gifts
  #
  def update
    store           = Store.find(params[:id])
    fetched_store   = Store.fetch(params[:name])
    type            = params[:name].downcase.to_sym

    case type
    when :gift
      store.change_products_to_gift
      store.destroy

      @store = nil
    when :unknown
      store.change_products_store_to_unknown
      store.destroy

      @store = nil
    else
      if fetched_store.nil? || store.id == fetched_store.id
        params[:is_approved] = true
        store.edit(params)

        @store = store
      else
        store.move_products_to(fetched_store)
        store.destroy

        @store = fetched_store
      end
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
