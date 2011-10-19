# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# Enable threaded mode
# config.threadsafe!

ActionController::Base.asset_host = File.join(
                                          CONFIG[:asset_host],
                                          CONFIG[:revision])


# Cache settings
#config.cache_store = :mem_cache_store, '10.194.250.118:11211'
config.action_controller.page_cache_directory = RAILS_ROOT + "/public/cache"
