# Observe events on the Suggestion model to keep 
# suggestion related cache stores persistent
#
class SuggestionSweeper < ActionController::Caching::Sweeper
  observe Suggestion

  # Fired when a suggestion is created
  #
  def after_create(suggestion)
    modify_suggestion_cache_key
  end

  # Fired when a suggestion is updated
  #
  def after_update(suggestion)
    modify_suggestion_cache_key
  end

  # Fired when a suggestion is destroyed
  #
  def after_destroy(suggestion)
    modify_suggestion_cache_key
  end

  # Modify the suggestion cache key used in all suggestion cache
  # values
  #
  def modify_suggestion_cache_key
    Configuration.write(
      ConfigurationVariable::SuggestionCacheKey,
      SecureRandom.hex(10))
  end

end
