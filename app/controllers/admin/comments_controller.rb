class Admin::CommentsController < ApplicationController
  before_filter :admin_required

  def index

    case params[:filter].to_sym
    when :recent
      @comments = Comment.with_user.with_purchase.by_id.limit(300)
      @view = "recent"
    end

    render @view
  end

end
