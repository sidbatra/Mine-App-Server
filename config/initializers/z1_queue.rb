include QueueManagement


QueueManager.setup(CONFIG[:aws_access_id],CONFIG[:aws_secret_key])

if Rails.env.start_with? 'p'
  proc_queue_name = [Rails.env,Q[:proc]].join("_")
  sec_proc_queue_name = [Rails.env,Q[:secondary_proc]].join("_")
else
  proc_queue_name = [Rails.env,CONFIG[:machine_id],Q[:proc]].join("_")
  sec_proc_queue_name = [Rails.env,CONFIG[:machine_id],Q[:secondary_proc]].join("_")
end

ProcessingQueue = QueueManagement::Queue.new proc_queue_name
SecondaryProcessingQueue = QueueManagement::Queue.new sec_proc_queue_name
