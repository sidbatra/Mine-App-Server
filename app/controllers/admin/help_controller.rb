class Admin::HelpController < ApplicationController
  before_filter :admin_required

  # List of routes and features of the admin UI
  #
  def show
  end
end
