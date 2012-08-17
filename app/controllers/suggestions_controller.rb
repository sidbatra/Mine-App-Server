class SuggestionsController < ApplicationController
  before_filter :login_required
  
  # Generate list of suggestions for the current user
  #
  def index
    #suggestion_ids = Purchase.select(:suggestion_id).
    #                  for_users([self.current_user]).
    #                  map(&:suggestion_id).uniq.compact

    @suggestions = Suggestion.select(:id,:title,:thing,:example,:image_path).
                    for_gender(self.current_user.gender).
                    by_weight.
                    limit(3)

    @suggestions << Suggestion.select(:id,:title,:thing,:example,:image_path).
                      for_thing("item").first

    #@suggestions.each do |suggestion| 
    #  suggestion[:done] = suggestion_ids.include? suggestion.id
    #end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end
end
