class Admin::CommentsController < ApplicationController
  before_filter :admin_required

  #
  #
  def index
    @filter = params[:filter].to_sym

    case @filter
    when :recent
      @comments = Comment.with_user.with_purchase.by_id.limit(300)
    end

    render :partial => @filter.to_s,
           :layout => "application"
  end

end
