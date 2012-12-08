set :output, "#{Dir.pwd}/log/cron.log"
set :environment, ENV['RAILS_ENV']

every 1.hour do
  rake "logs:upload"
end


every :tuesday, :at => '12:15pm' do
  runner "ProcessingQueue.push(CronWorker,:email_users_with_friend_activity,4.days.ago)"
end
every :friday, :at => '12:15pm' do
  runner "ProcessingQueue.push(CronWorker,:email_users_with_friend_activity,3.days.ago)"
end


#every :monday, :at => '9:00am' do
#  runner "ProcessingQueue.push(CronWorker,:mine_purchase_emails)"
#end
#
#every :wednesday, :at => '9:00am' do
#  runner "ProcessingQueue.push(CronWorker,:purchases_imported_reminder)"
#end


every 1.day, :at => '4:00pm' do
  runner "ProcessingQueue.push(CronWorker,:maintain_search_index)"
end

every 1.day, :at => '10:00pm' do
  runner "ProcessingQueue.push(CronWorker,:maintain_email_list)"
end


every 1.day, :at => '8:00am' do
  runner "ProcessingQueue.push(CronWorker,:email_users_after_joining_to_run_importer)"
end

every 1.day, :at => '8:30am' do
  runner "ProcessingQueue.push(CronWorker,:email_users_after_joining_to_download_app)"
end


every :sunday, :at => '5:00pm' do
  runner "ProcessingQueue.push(CronWorker,:email_add_purchase_reminder)"
end


#every 15.days, :at => '7:00am' do
#  runner "ProcessingQueue.push(CronWorker,:launch_crawl)"
#end

#every [:monday,:friday], :at => '6:00pm' do
#end
#every :sunday, :at => '8:15pm' do
#end
