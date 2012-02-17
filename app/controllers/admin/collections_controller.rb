# Handle collection related requests for the admin view
#
class Admin::CollectionsController < ApplicationController
  before_filter :admin_required

  # Fetch sets of collections based on different filters
  #
  def index
    @filter = params[:filter].to_sym

    case @filter
    when :recent
      @collections = Collection.with_user.by_id.limit(100)
    end

    render :partial => @filter.to_s,
           :layout  => "application"
  end
end
