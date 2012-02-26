set :output, "#{Dir.pwd}/log/cron.log"
set :environment, ENV['RAILS_ENV']

every 1.hour do
  rake "upload_logs_to_dump"
end


every 1.day, :at => '12:00pm' do
  runner "ProcessingQueue.push(CronWorker,:email_to_create_another_collection)"
end


every 3.days, :at => '6:00pm' do
  runner "ProcessingQueue.push(CronWorker,:scoop_users_with_no_items)"
end

every 3.days, :at => '6:15pm' do
  runner "ProcessingQueue.push(CronWorker,:scoop_users_with_no_friends)"
end

every 3.days, :at => '6:30pm' do
  runner "ProcessingQueue.push(CronWorker,:scoop_users_with_no_stores)"
end

every 3.days, :at => '6:45pm' do
  runner "ProcessingQueue.push(CronWorker,:scoop_users_with_no_collections)"
end


every :sunday, :at => '8:00pm' do
  runner "ProcessingQueue.push(CronWorker,:update_top_shoppers)"
end

every :sunday, :at => '8:15pm' do
  runner "ProcessingQueue.push(CronWorker,:email_to_create_another_product)"
end
