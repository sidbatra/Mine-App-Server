# Handle all requests & logic for onboarding
#
class WelcomeController < ApplicationController
  before_filter :login_required

  # Display the different steps during the onboarding
  #
  def show
    @filter = params[:id]

    case @filter
    when WelcomeFilter::Learn
      @view     = "show"
    when WelcomeFilter::Stores
      @shopping = Shopping.new
      @view     = "shoppings/new"
    when WelcomeFilter::Friends
      @view     = "invites/new"
    when WelcomeFilter::Style
      @styles   = CONFIG[:styles]
      @view     = "styles/new"
    when WelcomeFilter::Follow
      follows = 10
      stores  = self.current_user.stores

      raise IOError, "No stores found" unless stores.present?

      @users    = []
      per_store = follows / stores.length 

      stores.each do |store|
        @users += AchievementSet.current_top_shoppers(store.id).
                    map(&:achievable).
                    shuffle[0..per_store] 
      end

      @users      = @users.uniq.shuffle[0..follows-1]

      @shoppings  = Shopping.find_all_by_user_id(
                              @users.map(&:id),
                              :include    => :store).
                              select{|s| s.store.is_processed}.
                              group_by{|s| s.user_id}

      @view       = "followings/new"
    else
      raise IOError, "Incorrect welcome show ID"
    end

  rescue => ex
    handle_exception(ex)
  ensure
    @error ? redirect_to(root_path) : render(@view)
  end

  # Handle onboarding related post requests
  #
  def create
    @filter = params[:id] 

    case @filter
    when WelcomeFilter::Stores
      @success_target = user_path(
                          self.current_user.handle,
                          :src => UserShowSource::ShoppingsCreate)
      @error_target   = welcome_path(WelcomeFilter::Stores)

      store_ids = params[:store_ids].split(',')

      store_ids.each do |store_id|
        Shopping.add(
          self.current_user.id,
          store_id,
          ShoppingSource::User)
      end

    when WelcomeFilter::Follow
      @success_target = welcome_path(WelcomeFilter::Friends)
      @error_target   = welcome_path(WelcomeFilter::Follow)

      user_ids        = params[:user_ids].split(',')

      user_ids.each do |user_id|
        Following.add(
          user_id,
          self.current_user.id,
          FollowingSource::Suggestion,
          false)
      end

    when WelcomeFilter::Style
      @success_target = welcome_path(WelcomeFilter::Stores)
      @error_target   = welcome_path(WelcomeFilter::Style)

      self.current_user.update_attributes(:byline => params[:style])

    else
      @success_target  = welcome_path(WelcomeFilter::Learn)
      @error_target    = welcome_path(WelcomeFilter::Learn)

      raise IOError, "Incorrect welcome create ID"
    end

  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to @error ? @error_target : @success_target
  end

end
