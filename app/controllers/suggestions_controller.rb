class SuggestionsController < ApplicationController
  before_filter :login_required
  
  # Generate list of suggestions for the current user
  #
  def index
    suggestion_ids = Product.select(:suggestion_id).
                      for_user(self.current_user.id).
                      map(&:suggestion_id).compact.uniq
    @suggestions = Suggestion.by_weight.except(suggestion_ids)
  end
end
