class GoogleController < ApplicationController

  def create
    @usage = params[:usage] ? params[:usage].to_sym : :popup
    @error = params[:error]

    unless @error
      case @usage
      when :popup
        credentials = request.env['omniauth.auth']['credentials']
        info = request.env['omniauth.auth']['info']
        logger.info "#{credentials['token']} #{credentials['secret']} #{info['email']}"
        render :text => request.env['omniauth.auth'].to_yaml.gsub("\n","<br>")
      end
    else
      render :text => "FAILURE"
    end

  rescue => ex
    handle_exception(ex)
  ensure
  end

end
