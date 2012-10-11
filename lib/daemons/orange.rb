#!/usr/bin/env ruby

# Orange. Daemon for tweeting at people whose recent tweets contain
# a set of matching keywords.
#
# Output - Log. Written to log/clerk.rb.log
#


ENV['RAILS_PATH'] = File.dirname(__FILE__) + "/../../"
ORANGE_CONFIG     = YAML.load_file(File.join(
                                          ENV['RAILS_PATH'],
                                          'config/orange.yml'))

CONSUMER_KEY      = ORANGE_CONFIG[:consumer_key]
CONSUMER_SECRET   = ORANGE_CONFIG[:consumer_secret]
ACCESS_TOKEN      = ORANGE_CONFIG[:access_token]
ACCESS_TOKEN_SECRET = ORANGE_CONFIG[:access_token_secret]
ACCOUNTS          = ORANGE_CONFIG[:accounts].select{|account| account[:enabled] == true}
KEYWORDS          = %w{instagr.am pinterest obama 4sq facebook america}

require 'rubygems'
require 'tweetstream'
require 'eventmachine'


$running = true
Signal.trap("TERM") do 
  $running = false
end


@logger   = Logger.new(File.join(ENV['RAILS_PATH'],'log/orange.rb.log'))
@count    = 0 
@reset_at = Time.now - 10



TweetStream.configure do |config|
  config.consumer_key       = CONSUMER_KEY
  config.consumer_secret    = CONSUMER_SECRET
  config.oauth_token        = ACCESS_TOKEN
  config.oauth_token_secret = ACCESS_TOKEN_SECRET
  config.auth_method        = :oauth
end


EM.run do
  @client = TweetStream::Client.new

  @client.track("just bought") do |status|
    next if status.source.match /getmine.com/
    next if status.text.match /Stardoll|RT/
    next unless status.text.match /http/
    next if !status.in_reply_to_screen_name.nil? || 
            !status.in_reply_to_status_id.nil? || 
            !status.in_reply_to_user_id.nil?

    break if !$running


    @logger.info "#{status.user.screen_name}:#{status.user.name} - #{status.text}"

    name = ""
    name = status.user.name.split(" ").first if status.user.name

    next if name.nil? || name.length.zero? || Time.now < @reset_at


    tweet = "@#{status.user.screen_name} "\
            "#{ACCOUNTS[@count][:templates].choice[:tweet].gsub("@name",name)}"

    @logger.info "#{Time.now.to_s} #{tweet.length} #{tweet}"

    
    begin

      
      EM::Timer.new(30) do
        tweets = Twitter.search(KEYWORDS.sample, 
                          :lang => "en",
                          :rpp => ACCOUNTS.length, 
                          :result_type => "recent")

        ACCOUNTS.each_with_index do |account,i|
          Twitter.configure do |config|
            config.consumer_key       = CONSUMER_KEY
            config.consumer_secret    = CONSUMER_SECRET
            config.oauth_token        = account[:token] 
            config.oauth_token_secret = account[:secret] 
          end

          if @count == i
            Twitter.update(tweet,:in_reply_to_status_id => status.id)
          else
            Twitter.update(tweets[i].text.gsub(/@[^ ]+/,""))
          end

        end #accounts
      end #em

      @count += 1

      @reset_at = Time.now + rand(30) + 600
      @logger.info "Resetting"
      
      @count = 0 if @count >= ACCOUNTS.length

    rescue => ex
      @logger.info "Exception - #{ex.message}"
    end

    
    @logger.info "\n"
  end
end

@client.stop
