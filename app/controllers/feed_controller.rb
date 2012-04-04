class FeedController < ApplicationController
  before_filter :login_required

  # Fetch a feed of items(products only as of now) for
  # the current user.
  #
  # params[:page] - Integer:0. The page of feed items to fetch.
  # params[:per_page] - Integer:10. The number of feed items per page.
  # 
  def show
    @page = params[:page] ? params[:page].to_i : 0
    @per_page = params[:per_page] ? params[:per_page].to_i : 10
    @products = Product.
                  with_user.
                  with_store.
                  by_id.
                  offset(@page * @per_page).
                  limit(@per_page).
                  for_users(self.current_user.ifollowers + 
                            [self.current_user])
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

end
