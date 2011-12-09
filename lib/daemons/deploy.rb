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
      `cd #{ENV['RAILS_PATH']} && ruby script/deploy #{ENV['RAILS_ENV']} release`
      puts "Released at - #{Time.now}"
    end
  rescue => ex
    puts "Exception - " + ex.message + " - "
    puts "Backtrace - " + ex.backtrace.join("\n")
  end

  sleep 60
end
