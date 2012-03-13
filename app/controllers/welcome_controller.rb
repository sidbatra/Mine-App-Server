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
      @styles   = Style.by_weight
      @sender   = self.current_user.received_invites.last.user rescue nil
      @view     = "styles/new"
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

    when WelcomeFilter::Style
      @success_target = welcome_path(WelcomeFilter::Stores)
      @error_target   = welcome_path(WelcomeFilter::Style)

      style = Style.find(params[:style_id])

      self.current_user.update_attributes(
        :style_id => style.id,
        :byline => style.title)

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
