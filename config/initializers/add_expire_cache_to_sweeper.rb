# Add expire_cache method to Sweeper class
# to avoid having to use Sweeper in controllers
# and to wrap expire_fragment
#
class ActionController::Caching::Sweeper
  
  # Wrapper around expire_fragment to avoid
  # dupicating ActionController::Base.new 
  #
  def expire_cache(key)
    if Cache.active?
      ActionController::Base.new.expire_fragment(key)
    else
      ActiveRecord::Base.logger.info "Expired Fragment : " + key
    end
  end
end
