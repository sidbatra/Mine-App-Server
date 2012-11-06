
FIFO::QueueManager.setup(CONFIG[:aws_access_id],CONFIG[:aws_secret_key])

if Rails.env.start_with? 'd'
  prim_proc_queue_name = [Rails.env,CONFIG[:machine_id],Q[:primary_proc]].join("_") 
  proc_queue_name = [Rails.env,CONFIG[:machine_id],Q[:proc]].join("_")
  sec_proc_queue_name = [Rails.env,CONFIG[:machine_id],Q[:secondary_proc]].join("_")
  crawl_queue_name = [Rails.env,CONFIG[:machine_id],Q[:crawl]].join("_")
else
  prim_proc_queue_name = [Rails.env,Q[:primary_proc]].join("_")
  proc_queue_name = [Rails.env,Q[:proc]].join("_")
  sec_proc_queue_name = [Rails.env,Q[:secondary_proc]].join("_")
  crawl_queue_name = [Rails.env,Q[:crawl]].join("_")
end

PrimaryProcessingQueue = FIFO::Queue.new prim_proc_queue_name
ProcessingQueue = FIFO::Queue.new proc_queue_name
SecondaryProcessingQueue = FIFO::Queue.new sec_proc_queue_name
CrawlQueue = FIFO::Queue.new crawl_queue_name
