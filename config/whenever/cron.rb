set :output, "#{Dir.pwd}/log/cron.log"
set :environment, ENV['RAILS_ENV']

every 1.hour do
  rake "upload_logs_to_dump"
end

every 1.week, :at => '1:00am' do
  runner "ProcessingQueue.push(CronWorker,:update_top_shoppers)"
end
