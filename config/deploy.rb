require 'config/deploy/staging'
require 'config/deploy/production'
require 'config/deploy/helpers'
require 'config/deploy/deploy'
require 'config/deploy/db'
require 'config/deploy/solr'
require 'config/deploy/passenger'
require 'config/deploy/apache'
require 'config/deploy/monit'
require 'config/deploy/logrotate'
require 'config/deploy/cache'
require 'config/deploy/workers'
require 'config/deploy/gems'
require 'config/deploy/assets'
require 'config/deploy/permissions'
require 'config/deploy/cron'


set :application,   "mine"

set :scm,           :git
set :repository,    "git@github.com:Denwen/Mine-App-Server.git"
set :user,          "manager"  
set :deploy_via,    :remote_cache
set :keep_releases, 10
set :git_enable_submodules, 1

set :deploy_to,     "/vol/#{application}"
set :use_sudo,      false

default_run_options[:pty]   = true
ssh_options[:forward_agent] = true
ssh_options[:paranoid] = false


after "deploy:release", "deploy:cleanup"













