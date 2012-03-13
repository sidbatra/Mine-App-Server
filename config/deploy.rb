require 'config/deploy/staging'
require 'config/deploy/production'
require 'config/deploy/helpers'
require 'config/deploy/deploy'
require 'config/deploy/db'
require 'config/deploy/sphinx'
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


set :application,   "closet"

set :scm,           :git
set :repository,    "git@github.com:Denwen/Hasit-App-Server.git"
set :user,          "manager"  
set :deploy_via,    :remote_cache

set :deploy_to,     "/vol/#{application}"
set :use_sudo,      false

default_run_options[:pty]   = true
ssh_options[:forward_agent] = true
ssh_options[:paranoid] = false















