# Handle all requests & logic for onboarding
#
class WelcomeController < ApplicationController
  before_filter :login_required

  # Display the welcome page
  #
  def show
    @filter = params[:id]

    case @filter
    when WelcomeFilter::Learn
      @view     = "show"
    when WelcomeFilter::Stores
      @view     = "shoppings/new"

    when WelcomeFilter::Follow
      @users    = Cache.fetch(KEYS[:to_follow_users]){User.to_follow}[0..9]
      @view     = "followings/new"
    else
      raise IOError, "Incorrect welcome show ID"
    end

  rescue => ex
    handle_exception(ex)
  ensure
    @error ? redirect_to(home_path) : render(@view)
  end

  # Handle onboarding related post requests
  #
  def create
    @filter = params[:id] 

    case @filter
    when WelcomeFilter::Stores
      @success_target = welcome_path(WelcomeFilter::Follow)
      @error_target   = welcome_path(WelcomeFilter::Stores)

      store_ids = params[:store_ids].split(',')

      store_ids.each do |store_id|
        Shopping.add(
          self.current_user.id,
          store_id,
          ShoppingSource::User)
      end
    when WelcomeFilter::Follow
      @success_target = welcome_path(WelcomeFilter::Create,:category => 'shoes')
      @error_target   = welcome_path(WelcomeFilter::Follow)

      @users.each do |user|
        @followings << Following.add(
                        user.id,
                        self.current_user.id,
                        FollowingSource::Suggestion,
                        false)
      end
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
