class StaticController < ApplicationController

  # Display different static pages based on the aspect.
  #
  def show
    render :partial => params[:aspect].to_s,
           :layout  => "application"
  end
end
