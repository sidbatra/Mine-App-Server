class FeedController < ApplicationController
  before_filter :login_required

  # Fetch a feed of items(purchases only as of now) for
  # the current user.
  #
  # params[:after] - Integer(Unix timestamp). Only fetch feed items 
  #                   created after the given timestamp.
  # params[:before] - Integer(Unix timestamp). Only fetch feed items 
  #                   created before the given timestamp.
  # params[:per_page] - Integer:10. The number of feed items per page.
  #
  # params[:aspect] - Aspect of feed - a user feed or a special feed.
  # 
  def show
    @after = params[:after] ? Time.at(params[:after].to_i) : nil
    @before = params[:before] ? Time.at(params[:before].to_i) : nil
    @per_page = params[:per_page] ? params[:per_page].to_i : 10
    @aspect = params[:aspect] ? params[:aspect].to_sym : :user
    @cache_options = {}

    
    case @aspect
    when :user
    
      @key = ["v6",self.current_user,
              self.current_user.ifollowers.map(&:updated_at).max.to_i,
              "user-feed",@before ? @before.to_i : "",@per_page]

      @purchases = Purchase.
                    select(:id,:bought_at,:title,:handle,:source_url,
                            :orig_thumb_url,:orig_image_url,:endorsement,
                            :image_path,:is_processed,:user_id,:store_id,
                            :fb_action_id).
                    approved.
                    with_user.
                    with_store.
                    with_comments.
                    with_likes.
                    by_bought_at.
                    bought_after(@after).
                    bought_before(@before).
                    limit(@per_page).
                    for_users(self.current_user.ifollowers + 
                              [self.current_user]) unless fragment_exist? @key

    when :special

      @key = ["v1","special-feed"]
      @cache_options = {:expires_in => 30.minutes}
      @purchases = Purchase.
                    select(:id,:bought_at,:title,:handle,:source_url,
                            :orig_thumb_url,:orig_image_url,:endorsement,
                            :image_path,:is_processed,:user_id,:store_id,
                            :fb_action_id).
                    approved.
                    with_user.
                    with_store.
                    by_bought_at.
                    bought_after(@after).
                    bought_before(@before).
                    limit(@per_page).
                    special
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

end
