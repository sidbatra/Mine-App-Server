desc "Clear rails cache"


task :clear_cache do |e,args|

  require 'config/environment.rb'

  Rails.cache.clear

end
