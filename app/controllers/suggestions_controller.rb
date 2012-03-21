class SuggestionsController < ApplicationController
  before_filter :login_required
  
  # Generate list of suggestions for the current user
  #
  def index
    suggestion_ids = Product.select(:suggestion_id).
                      for_user(self.current_user.id).
                      map(&:suggestion_id).compact.uniq

    gender = self.current_user.gender.present? ?
              self.current_user.gender.capitalize :
              SuggestionGender.key_for(0)

    @suggestions = Suggestion.select(:id,:title).
                    for_gender(gender).
                    by_weight.
                    except(suggestion_ids).
                    limit(10)

    @key = KEYS[:user_product_suggestions] % 
            [self.current_user.id,
              Configuration.read(ConfigurationVariable::SuggestionCacheKey)]

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end
end
