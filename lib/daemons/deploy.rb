#!/usr/bin/env ruby

# Automatically deploy releases when a change is detected
#
# RAILS_PATH : String. Location of the rails app.
# RAILS_ENV : String. Deployment environment.
# BOT_PASSWORD : String. Password for the chat bot.
#
# Usage:
# RAILS_PATH=/vol/staging RAILS_ENV=staging BOT_PASSWORD=*** lib/daemons/deploy_ctl start
#

require 'rubygems'
require 'xmpp4r-simple'

bot_email = "deusexmachinaneo@gmail.com"
admin_email = "siddharthabatra@gmail.com"

$running = true
Signal.trap("TERM") do 
  $running = false
end

jabber = Jabber::Simple.new(bot_email,ENV['BOT_PASSWORD'])
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

      jabber.deliver(
        admin_email,
        "#{ENV['RAILS_ENV']} #{revision_sha[0..9]}")
    end
  rescue => ex
    logger.info "Exception at #{Time.now} - " + ex.message 

      jabber.deliver(
        admin_email,
        "#{ENV['RAILS_ENV']} FAILED")
  end

  sleep 60
end
