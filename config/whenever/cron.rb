set :output, "#{Dir.pwd}/log/cron.log"
set :environment, ENV['RAILS_ENV']

every 1.hour do
  rake "logs:upload"
end


every 1.day, :at => '12:15pm' do
  runner "ProcessingQueue.push(CronWorker,:email_users_with_friend_activity,1.day.ago)"
end


every 1.day, :at => '4:00pm' do
  runner "ProcessingQueue.push(CronWorker,:maintain_search_index)"
end


every [:monday,:friday], :at => '6:00pm' do
  runner "ProcessingQueue.push(CronWorker,:scoop_users_with_no_items)"
end

every :sunday, :at => '8:15pm' do
  runner "ProcessingQueue.push(CronWorker,:email_to_create_another_product)"
end
