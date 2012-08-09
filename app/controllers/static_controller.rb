class StaticController < ApplicationController

  # Display different static pages based on the aspect.
  #
  def show
    
    case params[:aspect].to_sym
    when :copyright
      @view = "copyright"
    when :privacy
      @view = "privacy"
    when :terms
      @view = "terms"
    when :about
      @origin = "about"
      @view = "about"
    when :faq
      @origin = "faq"
      @view = "faq"
    end

    render @view
  end
end
