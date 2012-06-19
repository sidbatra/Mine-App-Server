#!/usr/bin/env ruby

# Orange. Daemon for tweeting at people whose recent tweets contain
# a set of matching keywords.
#
# Output - Log. Written to log/clerk.rb.log
#


ENV['RAILS_PATH'] = File.dirname(__FILE__) + "/../../"


CONSUMER_KEY       = 'rGFRyGeuMegI45ZoQrK0Q'
CONSUMER_SECRET    = 'BiyIaWQTIejCXJomvmtgRpikwAJ4MX2cZL3J5gSQ'
OAUTH_TOKEN        = '45032868-LPwicmNtjVmIpNGtqQ4jD7MtfjjwAoDygJEiZeuK0'
OAUTH_TOKEN_SECRET = 'xr0FiF97RBqdqRHz7oPB9dwkM1ZKFg5XyGVflf3ApBk'


require 'rubygems'
require 'tweetstream'


LOGGER = Logger.new(File.join(ENV['RAILS_PATH'],"log/orange.rb.log"))
@logger = LOGGER

TweetStream.configure do |config|
  config.consumer_key       = CONSUMER_KEY
  config.consumer_secret    = CONSUMER_SECRET
  config.oauth_token        = OAUTH_TOKEN
  config.oauth_token_secret = OAUTH_TOKEN_SECRET
  config.auth_method        = :oauth
end

Twitter.configure do |config|
  config.consumer_key       = CONSUMER_KEY
  config.consumer_secret    = CONSUMER_SECRET
  config.oauth_token        = OAUTH_TOKEN
  config.oauth_token_secret = OAUTH_TOKEN_SECRET
end


@templates = [
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
  "http://getmine.com/try"]


@client = TweetStream::Daemon.new

@client.track("just bought") do |status|
  next if status.text.match "Stardoll"

  puts "#{status.user.screen_name}:#{status.user.name} - #{status.text}"

  name = ""
  name = status.user.name.split(" ").first if status.user.name

  next if name.nil? || name.length.zero?


  tweet = "@#{status.user.screen_name} #{@templates.choice.gsub("@name",name)}"

  puts "#{tweet.length} #{tweet}"

  begin
    #Twitter.update tweet
  rescue => ex
    puts "Exception - #{ex.message}"
  end
  
  puts "\n"
end

@client.stop
