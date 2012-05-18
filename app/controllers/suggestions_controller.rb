class SuggestionsController < ApplicationController
  before_filter :login_required
  
  # Generate list of suggestions for the current user
  #
  def index
    suggestion_ids = Purchase.select(:suggestion_id).
                      for_users([self.current_user.id]).
                      map(&:suggestion_id).uniq.compact

    @suggestions = Suggestion.select(:id,:title,:weight).
                    by_weight.
                    except(suggestion_ids)

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end
end
