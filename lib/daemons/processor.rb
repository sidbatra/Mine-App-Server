#!/usr/bin/env ruby

# Process objects from different models in the processing queue
#

require File.dirname(__FILE__) + "/../../config/environment"


$running = true
Signal.trap("TERM") do 
  $running = false
end


while($running) do
  payload = ProcessingQueue.pop

  if payload

    begin
      start_time = Time.now
      payload.process
      end_time = Time.now

      ActiveRecord::Base.logger.info "Finished processing "\
                                      "#{payload.klass} "\
                                      "#{payload.method} "\
                                      "#{end_time - start_time} "\
                                      "#{payload.arguments.join("|")}"
    rescue => ex
      if payload.recover?
        ActiveRecord::Base.logger.info "Recovering "\
                                        "#{payload.klass} "\
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
