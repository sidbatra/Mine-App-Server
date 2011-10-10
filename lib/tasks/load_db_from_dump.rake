desc "Populate the database from the given sql dump file"

task :load_db_from_dump,:db_dump,:revision  do |e,args|

  require 'config/environment.rb'

  db_dump   = args.db_dump
  revision  = args.revision
  env       = ENV['RAILS_ENV']
  config    = Rails::Configuration.new.database_configuration[env]
  host      = config["host"]
  password  = config["password"]
  user      = config["username"]

  system "mysql --user=#{user} --password=#{password} -h #{host} "\
         "denwen_#{env}_#{revision} < #{db_dump}"
end
