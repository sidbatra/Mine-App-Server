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
  payload = ProcessingQueue.pop
  payload = SecondaryProcessingQueue.pop unless payload

  if payload

    begin
      start_time = Time.now
      payload.process
      end_time = Time.now

      logger.info "Finished processing "\
                  "#{payload.object_name} "\
                  "#{payload.method} "\
                  "#{payload.arguments.join("|")} "\
                  "#{end_time - start_time}"

    rescue => ex
      if payload.recover?
        logger.info "Recovering "\
                    "#{payload.object_name} "\
                    "#{payload.method} "\
                    "#{payload.arguments.join("|")}"
        ProcessingQueue.push(payload)
      else
        LoggedException.add(__FILE__,__method__,ex)
      end
    end

  end 
  
  sleep 3
end
