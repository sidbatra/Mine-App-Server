#!/usr/bin/env ruby

# Automatically deploy releases when a change is detected
#
# RAILS_PATH=/vol/staging RAILS_ENV=staging lib/daemons/deploy_ctl start

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do

  begin 
    if `cd #{ENV['RAILS_PATH']} && git pull`.chomp != "Already up-to-date."
      `cd #{ENV['RAILS_PATH']} && ruby script/deploy release #{ENV['RAILS_ENV']}`
      puts "Released at - #{Time.now}"
    end
  rescue => ex
    LoggedException.add(__FILE__,__method__,ex)
  end

  sleep 60
end
