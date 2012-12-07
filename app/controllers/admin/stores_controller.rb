# Handle store related request for admin view
#
class Admin::StoresController < ApplicationController
  layout 'admin'
  before_filter :admin_required 
  before_filter :generate_uploader, :only => :edit

  # Fetch group of stores based on different filters 
  #
  def index

    case params[:filter].to_sym
    when :unapproved
      @approved_stores = Store.approved
      @stores = Store.unapproved.sorted
      @view = "unapproved"
      
    when :popular
      @stores = Store.purchases_count_gt(1).popular
      @view = "popular"

    when :crawlable
      @stores = Store.crawlable
      @view = "crawlable"

    when :parseable
      @stores = Store.with_email_parse_datum.parseable
      @view = "parseable"
    end

    render @view
  end

  # Display basic info and purchases at a store
  #
  def show
    @store = Store.find_by_handle(params[:id])
  end

  # Edit a store
  #
  def edit
    @store = Store.find_by_handle(params[:id])
  end

  # Update a store
  #
  def update
    store  = Store.find(params[:id])
    filter = params[:filter].to_sym

    case filter

    # Update the store name. If the updated name is already in the
    # database, then delete the store and move all its purchases to
    # the existing store. Also handle cases for unknowns. 
    when :unapproved
      fetched_store   = Store.fetch(params[:name])
      type            = params[:name].downcase.to_sym

      case type
      when :unknown
        store.change_purchases_store_to_unknown
        store.destroy

        @store = nil
      else
        if fetched_store.nil? || store.id == fetched_store.id
          params[:is_approved] = true
          store.generate_handle = true
          store.update_attributes(params)

          @store = store
        else
          store.move_purchases_to(fetched_store)
          store.destroy

          @store = fetched_store
        end
      end # type

    when :generic
      store.crawl_datum.update_attributes(params[:store][:crawl_datum])
      store.email_parse_datum.update_attributes(params[:store][:email_parse_datum])
      store.update_attributes(params[:store])

    end # filter
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.html do
        redirect_to edit_admin_store_path(store.handle)
      end
      format.json
    end
  end

end
