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

      revision_sha = `cd #{ENV['RAILS_PATH']} && git rev-parse HEAD`.chomp
      log_file     = "#{ENV['RAILS_PATH']}/log/#{revision_sha}.log"

      `cd #{ENV['RAILS_PATH']} && sudo RAILS_ENV=#{ENV['RAILS_ENV']} rake gems:install 1>&2 2> #{log_file}`
      `cd #{ENV['RAILS_PATH']} && rake deploy:release env=#{ENV['RAILS_ENV']} 1>&2 2>> #{log_file}`

      if `cat #{log_file}`.scan(/exception|error|fail|timeout/i).present?
        raise IOError, "Failed release"
      end

      logger.info "Released at - #{Time.now}"
    end
  rescue => ex
    logger.info "Exception at #{Time.now} - " + ex.message 
  end

  sleep 60
end
