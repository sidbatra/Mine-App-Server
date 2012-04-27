module DW
  
  # Class and methods to oversee operations of Cron on a 
  # distributed system
  #
  module Cron

    # Rails interface for the cron worker. This is only class
    # accessible to the cron schduler
    #
    class CronWorker
      
      # Ping users who have made a product to create another
      # product 
      #
      def self.email_to_create_another_product
        users = User.with_setting.products_count_gt(0)
        Mailman.prompt_users_to_create_another_product(users)

        HealthReport.add(HealthReportService::AnotherItemPrompt)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Email users with a digest of their friends activities 
      #
      def self.email_users_with_friend_activity(from)
        return
        products  = Purchase.with_store.made(from)
        
        owns_hash = {}
        products.each do |p|
          owns_hash[p.user_id] = [] unless owns_hash.has_key?(p.user_id)
          owns_hash[p.user_id] << p
        end

        users_with_activity = products.map(&:user_id).uniq
        user_ids            = Following.active.
                                find_all_by_user_id(users_with_activity).
                                map(&:follower_id).uniq

        users               = User.
                                with_ifollowers.
                                with_setting.
                                find_all_by_id(user_ids)

        Mailman.email_users_friend_activity_digest(
                  users,
                  users_with_activity,
                  owns_hash)

        HealthReport.add(HealthReportService::FriendsDigest)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Email users who haven't added an item to win them back
      #
      def self.scoop_users_with_no_items
        users = User.with_setting.products_count(0)
        Mailman.pester_users_with_no_items(users)

        HealthReport.add(HealthReportService::AddItemsPrompt)

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
