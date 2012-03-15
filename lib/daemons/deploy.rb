#!/usr/bin/env ruby

# Automatically deploy releases when a change is detected
#
# RAILS_PATH : String. Location of the rails app.
# RAILS_ENV : String. Deployment environment.
# REPO_BRANCH : String. Branch to checked for new commits.
# BOT_PASSWORD : String. Password for the chat bot.
#
# Usage:
# REPO_BRANCH=develop RAILS_PATH=/vol/staging RAILS_ENV=staging BOT_PASSWORD=*** lib/daemons/deploy_ctl start
#

require 'rubygems'
require 'xmpp4r-simple'
require 'grit'
require ENV['RAILS_PATH'] + '/lib/aws_management'

bot_email = "deusexmachinaneo@gmail.com"
admin_email = "siddharthabatra@gmail.com"

$running = true
Signal.trap("TERM") do 
  $running = false
end

repo = Grit::Repo.new(ENV['RAILS_PATH'])
jabber = Jabber::Simple.new(bot_email,ENV['BOT_PASSWORD'])
logger = Logger.new(File.join(ENV['RAILS_PATH'],"log/deploy.rb.log"))
config = YAML.load_file(File.join(
                          ENV['RAILS_PATH'],
                          'config',
                          'config.yml'))[ENV['RAILS_ENV']]

DW::AWSManagement::AWSConnection.establish(
                                  config[:aws_access_id],
                                  config[:aws_secret_key])


revision_sha = repo.commits(ENV['REPO_BRANCH']).first.id

while($running) do

  begin 
    `cd #{ENV['RAILS_PATH']} && git pull`

    new_revision_sha = repo.commits(ENV['REPO_BRANCH']).first.id

    if revision_sha != new_revision_sha

      revision_sha = new_revision_sha
      log_file     = "#{ENV['RAILS_PATH']}/log/#{revision_sha}.log"

      `cd #{ENV['RAILS_PATH']} && \
        sudo RAILS_ENV=#{ENV['RAILS_ENV']} \
        rake gems:install 1>&2 2> #{log_file}`

      `cd #{ENV['RAILS_PATH']} && \
        rake deploy:release env=#{ENV['RAILS_ENV']} 1>&2 2>> #{log_file}`

      if `cat #{log_file}`.scan(/exception|error|fail|timeout/i).present?
        raise IOError, "Failed release"
      end

      logger.info "Released #{revision_sha} at - #{Time.now}"

      jabber.deliver(
        admin_email,
        "#{ENV['RAILS_ENV']} #{revision_sha[0..9]}")
    end

  rescue => ex
    logger.info "Exception #{revision_sha} at #{Time.now} - " + ex.message 

    jabber.deliver(
      admin_email,
      "#{ENV['RAILS_ENV']} release FAILED")
  end


  begin
    unless DW::AWSManagement::Instance.all(
            :state => :running,
            :age => 5.minutes,
            :tags => {
              :installed => "0",
              :environment => ENV['RAILS_ENV']}).count.zero?

      revision_sha = `cd #{ENV['RAILS_PATH']} && git rev-parse HEAD`.chomp
      log_file     = "#{ENV['RAILS_PATH']}/log/#{revision_sha}_installation.log"

      `cd #{ENV['RAILS_PATH']} && \
        sudo RAILS_ENV=#{ENV['RAILS_ENV']} \
        rake gems:install 1>&2 2> #{log_file}`

      `cd #{ENV['RAILS_PATH']} && \
        rake deploy:install env=#{ENV['RAILS_ENV']} 1>&2 2>> #{log_file}`

      if `cat #{log_file}`.scan(/exception|error|fail|timeout/i).present?
        raise IOError, "Failed installation"
      end

      logger.info "Installed at - #{Time.now}"

      jabber.deliver(
        admin_email,
        "#{ENV['RAILS_ENV']} installed #{revision_sha[0..9]}")
    end

  rescue => ex
    logger.info "Exception installing at #{Time.now} - " + ex.message 

    jabber.deliver(
      admin_email,
      "#{ENV['RAILS_ENV']} installation FAILED")
  end


  sleep 60
end #while running

