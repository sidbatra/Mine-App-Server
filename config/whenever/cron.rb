set :output, "#{Dir.pwd}/log/cron.log"
set :environment, ENV['RAILS_ENV']

every 1.hour do
  rake "upload_logs_to_dump"
end

every 1.day, :at => '3:00pm' do
  runner "ProcessingQueue.push(CronWorker,:email_to_create_another_collection)"
end

every 1.week, :at => '2:00am' do
  runner "ProcessingQueue.push(CronWorker,:update_top_shoppers)"
end
