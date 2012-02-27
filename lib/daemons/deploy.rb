#!/usr/bin/env ruby

# Automatically deploy releases when a change is detected
#
# RAILS_PATH=/vol/staging RAILS_ENV=staging lib/daemons/deploy_ctl start

$running = true
Signal.trap("TERM") do 
  $running = false
end

logger = Logger.new(File.join(ENV['RAILS_PATH'],"log/deploy.rb.log"))

while($running) do

  begin 
    if `cd #{ENV['RAILS_PATH']} && git pull`.chomp != "Already up-to-date."
      `cd #{ENV['RAILS_PATH']} && sudo RAILS_ENV=#{ENV['RAILS_ENV']} rake gems:install`
      `cd #{ENV['RAILS_PATH']} && rake deploy:release env=#{ENV['RAILS_ENV']}`
      logger.info "Released at - #{Time.now}"
    end
  rescue => ex
    logger.info "Exception at #{Time.now} - " + ex.message 
    LoggedException.add(__FILE__,__method__,ex)
  end

  sleep 60
end
