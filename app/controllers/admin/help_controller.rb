class Admin::HelpController < ApplicationController
  before_filter :admin_required

  # List of routes and features of the admin UI
  #
  def show
    repo = Grit::Repo.new(RAILS_ROOT)
    @commits = repo.commits(
                RAILS_ENV == 'production' ? 'master' : 'develop').take(3)
  end
end
