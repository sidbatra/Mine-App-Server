class Admin::HelpController < ApplicationController
  layout nil
  before_filter :admin_required

  # List of routes and features of the admin UI
  #
  def show
    repo = Grit::Repo.new(RAILS_ROOT)
    @commits = repo.commits(
                RAILS_ENV == 'development' ? 'develop' : 'deploy').take(3)
  end
end
