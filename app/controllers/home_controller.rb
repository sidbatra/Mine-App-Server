class HomeController < ApplicationController

	def index
    @sample = params[:id].to_sym
    page = ""

    case @sample
    when :item
      page = "item"
    when :profile
      page = "profile"
    when :profile2
      page = "profile2"
    when :profile3
      page = "profile3"
    when :profile4
      page = "profile4"
    end

		render "home/samples/#{page}"
	end

  # Display the root path which is the feed is
  # the user is logged in or the home page is
  # the user isn't logged in.
  #
  def show
    if logged_in? && !params[:id]
      track_visit
      render "feed/show", :layout => "application"
    elsif params[:invited_by]
      session[:invited_by_user_id] = Cryptography.deobfuscate params[:invited_by]
      session[:origin] = "invite"

      redirect_to root_path
    else
      detect_origin
      redirect_to root_path if params[:id]

      if session[:invited_by_user_id]
        @invited_by_user = User.find session[:invited_by_user_id]
      end
    end
  end


  private 

  # Detect and store various tracking variables inside the session
  # and the curent request.
  #
  def detect_origin
    session[:home]    ||= 'story'
    session[:origin]  ||= params[:id] ? params[:id].to_s : 'direct'
    @home               = session[:home]
    @origin             = session[:origin]
  end

end
