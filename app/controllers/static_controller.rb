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
      @pierre = User.find_by_handle("pierre-legrain")
      @sid = User.find_by_handle("siddharth-batra")
      @deepak = User.find_by_handle("deepak-rao")

      @origin = "about"
      @view = "about"
    when :faq
      @origin = "faq"
      @view = "faq"
    end

    render @view
  end
end
