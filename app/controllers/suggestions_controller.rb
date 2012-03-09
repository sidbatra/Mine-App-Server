class SuggestionsController < ApplicationController
  before_filter :login_required
  
  # Generate list of suggestions for the current user
  #
  def index
    suggestion_ids = Product.select(:suggestion_id).
                      for_user(self.current_user.id).
                      map(&:suggestion_id).compact.uniq

    @suggestions = Suggestion.select(:id,:title).
                    by_weight.
                    except(suggestion_ids).
                    limit(10)

    @key = KEYS[:user_product_suggestions] % self.current_user.id

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end
end
