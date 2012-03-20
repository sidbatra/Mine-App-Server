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

      # Ping users who have made a collection to create another
      # collection
      #
      def self.email_to_create_another_collection
        users = User.with_setting.
                      with_collections_with_products.
                      created_collection_in(2.days.ago..Time.now)

        Mailman.prompt_users_to_create_another_collection(users)

        HealthReport.add(HealthReportService::AnotherCollectionPrompt)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

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
        products  = Product.with_store.created(from..Time.now) 
        wants     = Action.
                      on_type('product').
                      named(ActionName::Want).
                      created(from..Time.now).
                      with_actionable_and_owner

        
        owns_hash = {}
        products.each do |p|
          owns_hash[p.user_id] = [] unless owns_hash.has_key?(p.user_id)
          owns_hash[p.user_id] << p
        end

        wants_hash = {}
        wants.each do |w|
          wants_hash[w.user_id] = [] unless wants_hash.has_key?(w.user_id)
          wants_hash[w.user_id] << w.actionable
        end
        
        users_with_activity = (products + wants).map(&:user_id).uniq
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
                  owns_hash,
                  wants_hash)

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

      # Email users who haven't added a friend but have added an item
      # to win them back
      #
      def self.scoop_users_with_no_friends
        users = User.with_setting.products_count_gt(0).followings_count(0)
        Mailman.pester_users_with_no_friends(users)

        HealthReport.add(HealthReportService::AddFriendsPrompt)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Email users who haven't added a store but have added friends and items
      #
      def self.scoop_users_with_no_stores
        users = User.with_setting.
                  products_count_gt(0).
                  followings_count_gt(0).
                  shoppings_count(0)

        Mailman.pester_users_with_no_stores(users)

        HealthReport.add(HealthReportService::AddStoresPrompt)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Email users who haven't added a collection but have added 
      # stores, friends and items
      #
      def self.scoop_users_with_no_collections
        users = User.with_setting.
                  products_count_gt(0).
                  followings_count_gt(0).
                  shoppings_count_gt(0).
                  collections_count(0)

        Mailman.pester_users_with_no_collections(users)

        HealthReport.add(HealthReportService::AddCollectionsPrompt)

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
