# Abstracts the initialization away from config/environment.rb
#

MSG         = CONFIG[:msg]
EMAILS      = CONFIG[:emails]
Q           = CONFIG[:queue]
REGEX       = {}
REGEX[:url] = /(((http|ftp|https):\/\/){1}([a-zA-Z0-9_-]+)(\.[a-zA-Z0-9_-]+)+([\S,:\/\.\?=a-zA-Z0-9_-]*[^,.)\s"]))/i


# Include libs that require the environment to be loaded
#
require 'ar-extensions/adapters/mysql'
require 'ar-extensions/import/mysql'
#require File.join(RAILS_ROOT,'lib','extensions.rb')

# Include modules needed through the application lifetime
#
include DW
include CryptoManagement 
include ImageProcessing
include NotificationManagement
include Storage
include QueueManagement


# Disable updates in ThinkingSphinx to use the delayed delta
# gem without using delayed_job
#
#ThinkingSphinx.updates_enabled = false

ActionMailer::Base.delivery_method          = :amazon_ses
ActionMailer::Base.custom_amazon_ses_mailer = AWS::SES::Base.new(
                                                :access_key_id      => 
                                                    CONFIG[:aws_access_id],
                                                :secret_access_key  => 
                                                    CONFIG[:aws_secret_key])
