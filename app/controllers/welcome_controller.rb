class WelcomeController < ApplicationController
  before_filter :login_required

  # Display the different steps during the onboarding.
  #
  def show
    @filter = params[:id]

    case @filter
    when WelcomeFilter::Learn
      @view = "show"
    when WelcomeFilter::Share
      @view = "share"
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
    @filter = params[:id] 

    #case @filter
    #  @success_target  = welcome_path(WelcomeFilter::Learn)
    #  @error_target    = welcome_path(WelcomeFilter::Learn)

      raise IOError, "Incorrect welcome create ID"
    #end

  rescue => ex
    handle_exception(ex)
  ensure
    redirect_to @error ? @error_target : @success_target
  end

end
