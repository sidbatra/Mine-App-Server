# Oberve events on User models to keep various cache
# users persistent 
#
class UserSweeper < ActionController::Caching::Sweeper
  observe User

  # User is created
  #
  def after_create(user)
  end

  # User is updated
  #
  def after_update(user)
  end

  # User is deleted
  #
  def after_destroy(user)
  end

end
