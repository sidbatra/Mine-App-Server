set :output, "#{Dir.pwd}/log/cron.log"
set :environment, ENV['RAILS_ENV']

every 1.hour do
  rake "logs:upload"
end


every :wednesday, :at => '12:15pm' do
  runner "ProcessingQueue.push(CronWorker,:email_users_with_friend_activity,1.week.ago)"
end


every 1.day, :at => '4:00pm' do
  runner "ProcessingQueue.push(CronWorker,:maintain_search_index)"
end

every 1.day, :at => '9:00am' do
  runner "ProcessingQueue.push(CronWorker,:email_users_after_joining)"
end

#every [:monday,:friday], :at => '6:00pm' do
#end
#every :sunday, :at => '8:15pm' do
#end
