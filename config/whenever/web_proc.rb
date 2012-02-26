set :output, "#{Dir.pwd}/log/cron.log"
set :environment, ENV['RAILS_ENV']

every 1.hour do
  rake "upload_logs_to_dump"
end
