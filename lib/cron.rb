module DW
  
  # Class and methods to oversee operations of Cron on a 
  # distributed system
  #
  module Cron

    # Rails interface for the cron worker. This is only class
    # accessible to the cron schduler
    #
    class CronWorker

      # Public. Dispatch digest emails to all users whose friends
      # have added new purchaes in a time period.
      #
      # from - The Time period for preparing a digest.
      #
      def self.email_users_with_friend_activity(from)

        purchases = {}

        Purchase.with_store.made(from).each do |p|
          purchases[p.user_id] = [] unless purchases.key?(p.user_id)
          purchases[p.user_id] << p
        end

        user_ids = Following.active.
                    find_all_by_user_id(purchases.keys).
                    map(&:follower_id).uniq

        users = User.with_ifollowers.with_setting.find_all_by_id(user_ids)

        Mailman.email_users_friend_activity_digest(users,purchases,from)


        HealthReport.add(HealthReportService::FriendsDigest)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Public. Email users after a certain time period of joining.
      #
      def self.email_users_after_joining
        Mailman.after_join_suggestions

        HealthReport.add(HealthReportService::AfterJoinEmails)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Public. Reminder email for adding purachases.
      #
      def self.email_add_purchase_reminder
        Mailman.add_purchase_reminder

        HealthReport.add(HealthReportService::AddPurchaseEmails)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Maintain the search index 
      #
      def self.maintain_search_index
        
        include IndexManagement

        Index.regenerate
        Index.optimize

        HealthReport.add(HealthReportService::MaintainSearchIndex)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

    end #cron worker

  end # Cron
end # DW
