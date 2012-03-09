class Admin::StylesController < ApplicationController
  before_filter :admin_required 
  before_filter :generate_uploader, :only => [:new,:edit]

  # Display UI for creating a new style
  #
  def new
    @style = Style.new
  end

  # Create a new style
  #
  def create
    @style = Style.add(params[:style])

    redirect_to @style.valid? ? 
                  admin_styles_path :
                  new_admin_style_path
  end

  # List all styles
  #
  def index
    @styles = Style.by_weight
  end

  # Display UI for editing a style
  #
  def edit
    @style = Style.find(params[:id])
  end

  # Update style
  #
  def update
    @style = Style.find(params[:id])
    @style.update_attributes(params[:style])

    redirect_to @style.valid? ? 
                  admin_styles_path :
                  new_admin_style_path
  end

  # Destroy a style
  #
  def destroy
    Style.find(params[:id]).destroy
    redirect_to admin_styles_path
  end

end
