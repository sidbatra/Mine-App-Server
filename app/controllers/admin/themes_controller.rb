class Admin::ThemesController < ApplicationController
  layout 'admin'
  before_filter :admin_required 
  before_filter :generate_uploader, :only => [:new,:edit]

  # Display UI for creating a new theme
  #
  def new
    @theme = Theme.new
  end

  # Create a new theme
  #
  def create
    @theme = Theme.create(params[:theme])

    redirect_to @theme.valid? ? 
                  admin_themes_path :
                  new_admin_theme_path
  end

  # List all themes
  #
  def index
    @themes = Theme.by_weight
  end

  # Display a theme
  #
  def show
    @theme = Theme.find(params[:id])
  end

  # Display UI for editing a theme
  #
  def edit
    @theme = Theme.find(params[:id])
  end

  # Update theme
  #
  def update
    @theme = Theme.find(params[:id])
    @theme.update_attributes(params[:theme])

    redirect_to @theme.valid? ? 
                  admin_themes_path :
                  edit_admin_theme_path(@theme)
  end

  # Destroy a theme
  #
  def destroy
    Theme.find(params[:id]).destroy
    redirect_to admin_themes_path
  end

end
