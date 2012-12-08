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

        Purchase.approved.with_store.made(from).each do |p|
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

      def self.mine_purchase_emails
        users = User.all(:conditions => {:email_mined_till_ne => "NULL"})

        users.each do |user|
        begin
          extractor = PurchaseExtractor.new user.email_mined_till
          extractor.mine_emails_for_user user
          #SecondaryProcessingQueue.push extractor,
          #                          :mine_emails_for_user,
          #                          user
        rescue => ex
          LoggedException.add(__FILE__,__method__,ex)
        end
        end

        HealthReport.add(HealthReportService::MinePurchaseEmails)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Public. Find crawlable stores and launch a crawl job
      # via the crawl queue.
      #
      def self.launch_crawl
        json = Store.crawlable.with_crawl_datum.map do |store|
                { :id => store.id, 
                  :domain => store.domain, 
                  :launch_url => store.crawl_datum.launch_url,
                  :use_og_image => store.crawl_datum.use_og_image}
               end.to_json

        CrawlQueue.push(Object.const_set("Crawler",Class.new),:start,json)

        HealthReport.add(HealthReportService::LaunchCrawl)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Public. Fetch list of failed emails and modify
      # receiving users subscription settings.
      #
      def self.maintain_email_list
        return unless Rails.env.starts_with? 'p'

        email_feedback_queue = FIFO::Queue.new Q[:email_feedback]

        while(true)
          payload = email_feedback_queue.pop :raw => true
          break unless payload

          message = JSON.parse(payload)["Message"]
          next unless message

          message = JSON.parse message
          next unless (message["notificationType"] == "Bounce" && 
                        message["bounce"]["bounceType"] == "Permanent") ||
                      message["notificationType"] == "Complaint"

          messageID = message["mail"]["messageId"]
          email = Email.find_by_message_id messageID
          next unless email

          user = User.find email.recipient_id
          user.setting.unsubscribe if user
        end

        HealthReport.add(HealthReportService::MaintainEmailList)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

    end #cron worker

  end # Cron
end # DW
