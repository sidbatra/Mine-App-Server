# Add expire_cache method to Sweeper class
# to avoid having to use Sweeper in controllers
# and to wrap expire_fragment
#
class ActionController::Caching::Sweeper
  
  # Wrapper around expire_fragment to avoid
  # dupicating ActionController::Base.new 
  #
  def expire_cache(key)
    ActionController::Base.new.expire_fragment(key)
  end
end
