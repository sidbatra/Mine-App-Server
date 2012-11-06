#!/usr/bin/env ruby

# Process objects from different models in the processing queue
#

ENV['RAILS_PATH'] = File.dirname(__FILE__) + "/../../"

require File.dirname(__FILE__) + "/../../config/environment"


$running = true
Signal.trap("TERM") do 
  $running = false
end

logger = Logger.new(File.join(RAILS_ROOT,"log/processor.rb.log"))


while($running) do
  payload = PrimaryProcessingQueue.pop
  payload ||= ProcessingQueue.pop
  #payload ||= SecondaryProcessingQueue.pop 

  if payload

    begin
      start_time = Time.now
      payload.process
      end_time = Time.now

      logger.info "Finished #{payload.to_s} #{end_time - start_time}"

    rescue => ex
      if payload.attempts < CONFIG[:max_processing_attempts]
        logger.info "Recovering #{payload.to_s}"
        payload.retry
      else
        LoggedException.add(__FILE__,__method__,ex)
      end
    end

  end 
  
  sleep 3
end
