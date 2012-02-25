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
                      collections_count_gt(0)

        Mailman.prompt_users_to_create_another_collection(users)

        HealthReport.add(HealthReportService::AnotherCollectionPrompt)

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Ping users who have made a product to create another
      # product 
      #
      def self.email_to_create_another_product
        users = User.products_count_gt(0)
        Mailman.prompt_users_to_create_another_product(users)

        HealthReport.add(HealthReportService::AnotherItemPrompt)

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

    end #cron worker

  end # Cron
end # DW
