# Abstracts the initialization away from config/environment.rb
#

EMAILS      = CONFIG[:emails]
KEYS        = CONFIG[:keys]
Q           = CONFIG[:queue]
REGEX       = {}
REGEX[:url] = /(((http|ftp|https):\/\/){1}([a-zA-Z0-9_-]+)(\.[a-zA-Z0-9_-]+)+([\S,:\/\.\?=a-zA-Z0-9_-]*[^,.)\s"]))/i


# Include libs that require the environment to be loaded
#
require 'ar-extensions/adapters/mysql'
require 'ar-extensions/import/mysql'
require File.join(RAILS_ROOT,'lib','extensions.rb')


# Include modules needed through the application lifetime
#
include DW
include Enumerations

# Populate enumerations
enums = YAML.load_file("#{RAILS_ROOT}/config/enumerations.yml")
DW::Enumerations.populate(enums[:ruby])

include AmazonProductInterface
include CacheManagement
include Cron
include CryptoManagement 
include ImageProcessing
include NotificationManagement
include MailmanInterface
include Storage
include QueueManagement
include DistributionManagement
include WebSearchInterface


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
