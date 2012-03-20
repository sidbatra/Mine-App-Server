set :output, "#{Dir.pwd}/log/cron.log"
set :environment, ENV['RAILS_ENV']

every 1.day, :at => '4:00pm' do
  runner "ProcessingQueue.push(CronWorker,:maintain_search_index)"
end
