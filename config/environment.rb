# Be sure to restart your server when you modify this file

RAILS_LOC = Dir.pwd

ENV['RAILS_ENV']    ||= 'production'
ENV['RAILS_PATH']   ||= '.'
ENV['CACHE_IN_DEV'] = 'false'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'drb'
require File.join(RAILS_ROOT,'lib','authentication_system.rb')
require File.join(RAILS_ROOT,'lib','request_management.rb')

Rails::Initializer.run do |config|

  CONFIG = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]

  local_config = "#{RAILS_ROOT}/config/config.local.yml"
  
  if File.exists? local_config
    CONFIG.merge!(YAML.load_file(local_config)[RAILS_ENV]) 
  end

  CONFIG[:machine_id] = `ec2-metadata -i`.chomp.split(" ").last
  CONFIG[:revision]   = `cd #{ENV['RAILS_PATH']} && git rev-parse HEAD`.chomp

  config.gem('amazon-ecs',
              :version => '2.2.4',
              :lib => 'amazon/ecs')
  config.gem('ar-extensions', 
              :version => '0.9.2')
  config.gem('aws-s3',
              :lib => 'aws/s3',
              :version => '0.6.2')
  config.gem('aws',
              :version => '2.5.6')
  config.gem('aws-ses', 
              :lib => 'aws/ses', 
              :version => '0.4.3')
  config.gem('daemons', 
              :version => '1.1.0',
              :lib => false)
  config.gem('fb_graph',
              :version => '2.5.2')
  config.gem('gmail',
              :version => '0.4.0',
              :lib => false)
  config.gem('tumblife',
              :version => '1.2.0')
  config.gem('grit',
              :version => '2.4.1',
              :lib => false)
  config.gem('jammit',
              :version => '0.6.3')
  config.gem('jbuilder',
              :version => '0.4.0')
  config.gem('mechanize', 
              :version => '2.1.1',
              :lib => false)
  config.gem('mini_magick', 
              :version => '3.4',
              :lib => false)
  config.gem('oauth',
              :version => '0.4.6')
  config.gem('omniauth',
              :version => '1.1.1')
  config.gem('omniauth-google',
              :version => '1.0.2')
  config.gem('pismo',
              :version => '0.7.2',
              :lib => false)
  config.gem('ruby-hmac',
              :version => '0.4.0',
              :lib => false)
  config.gem('rb-inotify',
              :version => '0.8.8',
              :lib => false)
  config.gem('sunspot',
              :version => '1.3.1')
  config.gem('sunspot_solr',
              :version => '1.3.1',
              :lib => false)
  config.gem('sunspot_rails',
              :version => '1.3.1')
  config.gem('typhoeus',
              :version => '0.3.3')
  config.gem('twitter',
              :version => '2.5.0',
              :lib => false)
  config.gem('twitter_oauth',
              :version => '0.4.3')
  config.gem('xmpp4r',
              :version => '0.5',
              :lib => false)
  config.gem('xmpp4r-simple',
              :version => '0.8.8',
              :lib => false)

  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Add custom folders
  config.autoload_paths +=  [
                              File.join(Rails.root,'app','observers'),
                              File.join(Rails.root,'app','processors'),
                              File.join(Rails.root,'app','presenters'),
                              File.join(Rails.root,'app','delayed_observers')]


  # Register observers
  config.active_record.observers  = :purchase_observer, :user_observer, 
                                    :following_observer, :store_observer, 
                                    :invite_observer, :product_observer,
                                    :comment_observer, :like_observer,
                                    :setting_observer, :notification_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.action_mailer.default_url_options = { :host => CONFIG[:host] }

  config.time_zone = 'Pacific Time (US & Canada)'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

