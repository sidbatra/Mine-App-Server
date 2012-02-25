module DW
  
  # Class and methods to oversee operations of Cron on a 
  # distributed system
  #
  module Cron

    # Rails interface for the cron worker. This is only class
    # accessible to the cron schduler
    #
    class CronWorker
      
      # Stitch together Store model methods and Mailman
      # to update and notify top shoppers
      #
      def self.update_top_shoppers
        Store.update_top_shoppers do |store,users| 
          Mailman.notify_top_shoppers(store,users)
        end

        HealthReport.add(HealthReportService::TopShopperUpdate)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end
    end

  end # Cron
end # DW
