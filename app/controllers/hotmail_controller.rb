class HotmailController < ApplicationController
  before_filter :login_required

  def create
    @usage = params[:usage] ? params[:usage].to_sym : :popup
    @status = nil

    case @usage
    when :popup
      email = params[:email]
      password = params[:password]

      @status = HotmailConnection.validate email,password

      if @status
        self.current_user.hm_email = email
        self.current_user.hm_password = password
        self.current_user.save!
      end
    end

  rescue => ex
    handle_exception(ex)
  ensure
  end
end
