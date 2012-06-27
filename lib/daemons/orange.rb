#!/usr/bin/env ruby

# Orange. Daemon for tweeting at people whose recent tweets contain
# a set of matching keywords.
#
# Output - Log. Written to log/clerk.rb.log
#


ENV['RAILS_PATH'] = File.dirname(__FILE__) + "/../../"


CONSUMER_KEY       = '5M8DIWAdEJRKlTW5d9vw'
CONSUMER_SECRET    = 'JSSRkH53nsTbvppypEmsmWJHini1CE0PJuwWV8ck4sc'
OAUTH_TOKEN        = ['20894612-Wb7ffoyvFSXnlyAJt44bCVuOFwegcoVDqsSiX6K04','158595960-hIOCkVpoyRAbQl6y2QgdDjYnkpGwEPOnWczk5HPA']
OAUTH_TOKEN_SECRET = ['cqbjSW2hVVx6bH7PRl5TJYyIiy0lxTQOuLe4W20gnU','B9cTjc6HZ0Pso03d1LVzEhDBYOYqNzMxoernFcY9zg']


require 'rubygems'
require 'tweetstream'


$running = true
Signal.trap("TERM") do 
  $running = false
end


@logger = Logger.new(File.join(ENV['RAILS_PATH'],"log/orange.rb.log"))


TweetStream.configure do |config|
  config.consumer_key       = CONSUMER_KEY
  config.consumer_secret    = CONSUMER_SECRET
  config.oauth_token        = OAUTH_TOKEN[0]
  config.oauth_token_secret = OAUTH_TOKEN_SECRET[0]
  config.auth_method        = :oauth
end


@templates = [
  [
  "@name I've built a site called 'Mine' "\
  "for tweeting stuff you've bought. See if you like "\
  "http://getmine.com/try",
  "@name I just built a site called "\
  "'Mine' for doing that! Try http://getmine.com/try ",
  "That's awesome @name - I just built a "\
  "site called 'Mine' for doing that! try it out! http://getmine.com/try",
  "Hey @name, saw that and thought you "\
  "could use a site called 'Mine' http://getmine.com/try (yes, I built it "\
  ":))",
  "Awesome! I'm actually working on a site for "\
  "sharing cool stuff you buy - you can try it out here: "\
  "http://getmine.com/try"],
  [
  "@name have you heard of Mine, a site for tweeting "\
  "about things you buy? It's awesome! http://getmine.com/try",
  "Hey @name don't you use Mine for tweeting about things you buy? "\
  "Really, really easy! http://getmine.com/try",
  "Try tweeting stuff you've bought through Mine - it's a great "\
  "new service I'm building: http://getmine.com/try",
  "@name Have you tried Mine for tweeting your stuff? "\
  "like this: http://getmine.com/Deepak-Rao/p/Nike-Fuel-Band", 
  "Try http://getmine.com/try for tweeting pics of your stuff! "\
  "e.g my new Nike fuel band: http://bit.ly/NCbHUF"]
]

@count = 0
@reset_at = Time.now - 10
@client = TweetStream::Client.new

@client.track("just bought") do |status|
  next if status.text.match /Stardoll|RT/
  next unless status.text.match /http/
  next if !status.in_reply_to_screen_name.nil? || 
          !status.in_reply_to_status_id.nil? || 
          !status.in_reply_to_user_id.nil?

  @logger.info "#{status.user.screen_name}:#{status.user.name} - #{status.text}"

  name = ""
  name = status.user.name.split(" ").first if status.user.name

  next if name.nil? || name.length.zero? || Time.now < @reset_at


  tweet = "@#{status.user.screen_name} "\
          "#{@templates[@count].choice.gsub("@name",name)}"

  @logger.info "#{Time.now.to_s} #{tweet.length} #{tweet}"


  Twitter.configure do |config|
    config.consumer_key       = CONSUMER_KEY
    config.consumer_secret    = CONSUMER_SECRET
    config.oauth_token        = OAUTH_TOKEN[@count]
    config.oauth_token_secret = OAUTH_TOKEN_SECRET[@count]
  end

  
  begin
    @count += 1
    Twitter.update(tweet,:in_reply_to_status_id => status.id)

    @reset_at = Time.now + rand(60) + 150
    @logger.info "Resetting"
    
    @count = 0 if @count >= 2

  rescue => ex
    @logger.info "Exception - #{ex.message}"
  end


  break if !$running
  
  @logger.info "\n"
end

@client.stop
