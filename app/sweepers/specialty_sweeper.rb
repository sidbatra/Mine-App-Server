# Observe events on the Specialty model to keep 
# specialty related cache stores persistent
#
class SpecialtySweeper < ActionController::Caching::Sweeper
  observe Specialty

  # Fired when a specialty is created
  #
  def after_create(specialty)
    expire_store_specialty(specialty)
  end

  # Fired when a specialty is updated
  #
  def after_update(specialty)
    expire_store_specialty(specialty)
  end

  # Fired when a specialty is destroyed
  #
  def after_destroy(specialty)
    expire_store_specialty(specialty)
  end

  # Expire related store cache for specialty category_id
  #
  def expire_store_specialty(specialty)
    expire_cache(KEYS[:store_related_in_category] % specialty.category_id)
  end
end
