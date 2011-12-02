class WelcomeController < ApplicationController
  before_filter :login_required

  # Display the welcome page
  #
  def show
  end

end
