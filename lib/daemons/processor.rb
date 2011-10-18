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
      payload.process

      ActiveRecord::Base.logger.info payload.klass + " - processed with " + 
                                      payload.arguments.join(" - ")
    rescue => ex
      if payload.recover?
        ActiveRecord::Base.logger.info "Recovering - #{payload.attempts}"
        ProcessingQueue.push(payload)
      else
        LoggedException.add(__FILE__,__method__,ex)
      end
    end

  end 
  
  sleep 3
end
