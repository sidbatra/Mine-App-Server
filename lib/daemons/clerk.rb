#!/usr/bin/env ruby

# Clerk. Daemon for reacting to changes to specific files on the
# filesystem. Use cases:
# * Generate javascript config & enumeration files when base yaml is modified.
# * Generate css files from less files.
#
# ENV['RAILS_PATH'] - String. Root folder for the Rails application.
# ENV['RAILS_ENV'] - String. Current Rails environment.
#
# Output - Log. Written to log/clerk.rb.log
#
# Usage - RAILS_ENV=development RAILS_PATH=/vol/closet lib/daemons/clerk_ctl start
#

require 'rubygems'
require 'rb-inotify'

LOGGER = Logger.new(File.join(ENV['RAILS_PATH'],"log/clerk.rb.log"))


# Recreate javascript enumerations file after the base yaml
# file is changed.
#
# Boolean - true
#
def generate_js_enums
  LOGGER.info "Remaking js enums"
  system("cd #{ENV['RAILS_PATH']} && rake js:dump:enums")
  true
end

# Recreate javascript config file after the base yaml
# file is changed.
#
# Boolean - true
#
def generate_js_config
  LOGGER.info "Remaking js config"
  system("cd #{ENV['RAILS_PATH']} && rake js:dump:config")
  true
end


$running = true
Signal.trap("TERM") do 
  $running = false
  notifier.stop
end

notifier  = INotify::Notifier.new

notifier.watch(File.join(ENV['RAILS_PATH'],'config'),:moved_to) do |event| 
  if event.name.match(/^enumerations.yml/)
    generate_js_enums
  elsif event.name.match(/^config.yml/)
    generate_js_config
  end
end

notifier.watch(File.join(ENV['RAILS_PATH'],'config/enumerations.yml'),:modify) do |event| 
  generate_js_enums
end

notifier.watch(File.join(ENV['RAILS_PATH'],'config/config.yml'),:modify) do |event| 
  generate_js_config
end

while($running) do
  notifier.run
end

