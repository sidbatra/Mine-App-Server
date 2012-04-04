class FeedController < ApplicationController
  before_filter :login_required

  # Fetch a feed of items(products only as of now) for
  # the current user.
  #
  # params[:after] - Integer(Unix timestamp). Only fetch feed items 
  #                   created after the given timestamp.
  # params[:before] - Integer(Unix timestamp). Only fetch feed items 
  #                   created before the given timestamp.
  # params[:per_page] - Integer:10. The number of feed items per page.
  # 
  def show
    @after = params[:after] ? Time.at(params[:after].to_i) : nil
    @before = params[:before] ? Time.at(params[:before].to_i) : nil
    @per_page = params[:per_page] ? params[:per_page].to_i : 10
    @products = Product.
                  with_user.
                  with_store.
                  by_id.
                  after(@after).
                  before(@before).
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
