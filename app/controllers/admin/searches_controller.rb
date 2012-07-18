class Admin::SearchesController < ApplicationController
  before_filter :admin_required

  #
  #
  def index

    case params[:filter].to_sym
    when :recent
      searches = Search.with_user.by_id.limit(500)
      purchases = Purchase.with_user.by_id.limit(500)

      @set  = (searches + purchases).sort do |x,y| 
                x.created_at <=> y.created_at
              end
      first_search = @set.index{|item| item.is_a? Search}
      @set = @set.slice(first_search-1,@set.length-1)


      @view = "recent"
    end

    render @view
  end
end
