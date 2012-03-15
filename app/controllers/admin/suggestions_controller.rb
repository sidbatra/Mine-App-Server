class Admin::SuggestionsController < ApplicationController
  before_filter :admin_required 
  before_filter :generate_uploader, :only => [:new,:edit]

  # Display UI for creating a new suggestion
  #
  def new
    @suggestion = Suggestion.new
  end

  # Create a new suggestion
  #
  def create
    @suggestion = Suggestion.add(params[:suggestion])

    redirect_to @suggestion.valid? ? 
                  admin_suggestions_path :
                  new_admin_suggestion_path
  end

  # List all suggestions
  #
  def index
    @suggestions = Suggestion.by_weight
  end

  # Display a suggestion
  #
  def show
    @suggestion = Suggestion.with_products.find(params[:id])
  end

  # Display UI for editing a suggestion
  #
  def edit
    @suggestion = Suggestion.find(params[:id])
  end

  # Update suggestion
  #
  def update
    @suggestion = Suggestion.find(params[:id])
    @suggestion.update_attributes(params[:suggestion])

    redirect_to @suggestion.valid? ? 
                  admin_suggestions_path :
                  edit_admin_suggestion_path(@suggestion)
  end

  # Destroy a suggestion
  #
  def destroy
    Suggestion.find(params[:id]).destroy
    redirect_to admin_suggestions_path
  end

end
