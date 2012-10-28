class WelcomeController < ApplicationController
  before_filter :login_required

  # Display the different steps during the onboarding.
  #
  def show
    @filter = params[:id]

    case @filter
    when WelcomeFilter::Info
      @view = "info"

    when WelcomeFilter::Learn
      @view = "show"

    when WelcomeFilter::History
      @view = "purchases/index"

    when WelcomeFilter::Create
      @suggestions = Suggestion.select(:id,:title,:thing,:example,:image_path).
                      for_gender(self.current_user.gender).
                      by_weight.
                      limit(3)
      @suggestions << Suggestion.select(:id,:title,:thing,
                                              :example,:image_path).
                                      for_thing("item").first

      @current_suggestion_id = params[:suggestion_id] ? 
                                params[:suggestion_id] : 0

      @view = "create"
    else
      raise IOError, "Incorrect welcome show ID"
    end

  rescue => ex
    handle_exception(ex)
  ensure
    @error ? redirect_to(root_path) : render(@view)
  end

  # Handle onboarding related post requests.
  #
  def create
    @filter = params[:filter].to_sym

    case @filter
    when :info
      @success_target = welcome_path(WelcomeFilter::Learn)
      @error_target   = welcome_path(WelcomeFilter::Info)

      other_user = User.find_by_email params[:email]

      if other_user && other_user.id != self.current_user.id
        @error = true
        @error_target = welcome_path(WelcomeFilter::Info,:exists => true)
      else
        self.current_user.update_attributes(params)

        @success_target = root_path unless self.current_user.purchases_count.zero?
      end
    else

     raise IOError, "Incorrect welcome create ID"
    end

  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to @error ? @error_target : @success_target
  end

end
