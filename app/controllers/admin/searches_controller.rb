class Admin::SearchesController < ApplicationController
  layout 'admin'
  before_filter :admin_required

  #
  #
  def index

    case params[:filter].to_sym
    when :creation
      searches = Search.for(SearchSource::New).with_user.by_id.limit(500)
      purchases = Purchase.with_user.by_id.limit(500)

      @set  = (searches + purchases).sort do |x,y| 
                x.created_at <=> y.created_at
              end
      first_search = @set.index{|item| item.is_a? Search}
      @set = @set.slice(first_search-1,@set.length-1)


      @view = "creation"

    when :user
      @searches = Search.for(SearchSource::User).with_user.by_id.limit(500)

      @view = "user"

    when :purchase
      @searches = Search.for(SearchSource::Purchase).with_user.by_id.limit(500)

      @view = "purchase"
    end

    render @view
  end
end
