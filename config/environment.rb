# Be sure to restart your server when you modify this file

RAILS_LOC = Dir.pwd

ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.11' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'drb'
require File.join(RAILS_ROOT,'lib','authentication_system.rb')
require File.join(RAILS_ROOT,'lib','request_management.rb')

Rails::Initializer.run do |config|

  CONFIG = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]

  CONFIG[:machine_id] = `ec2-metadata -i`.chomp.split(" ").last
  CONFIG[:revision]   = `git rev-parse HEAD`.chomp

  config.gem('ar-extensions', 
              :version => '0.9.2')
  config.gem('aws',
              :version => '2.5.6')
  config.gem('aws-s3',
              :lib => 'aws/s3',
              :version => '0.6.2')
  config.gem('aws-ses', 
              :lib => 'aws/ses', 
              :version => '0.4.3')
  config.gem('daemons', 
              :version => '1.1.0')
  config.gem('mini_magick', 
              :version => '2.1')
  config.gem('fb_graph',
              :version => '2.1.10')
  config.gem('jammit',
              :version => '0.6.3')

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
                              File.join(Rails.root,'app','sweepers')]


  # Register observers
  config.active_record.observers  = :product_observer, :comment_observer, 
                                    :user_observer, :following_observer,
                                    :action_observer, :store_observer,
                                    :store_sweeper


  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.action_mailer.default_url_options = { :host => CONFIG[:host] }

  config.time_zone = 'Pacific Time (US & Canada)'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end
