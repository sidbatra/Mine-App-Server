module DW

  # Set of classes to simuate enumerations
  #
  module Enumerations

    # Base class for all enumerations
    #
    class Enumeration
      
      # Return an array of values of the constants of the class.
      # This is useful if the Enumeration holds types that map 
      # to ActiveRecord columns that require validation for inclusion
      #
      def self.values
        constants.map{|constant| class_eval constant}
      end

      # Returns the key for the given value
      #
      def self.key_for(value)
        self.values_hash[value]
      end

      protected

      # Returns a hash that maps the values of constants back to
      # their names. Hash is generated at runtime when first request.
      # After this the hash is kept in a class variable and not regenerated
      #
      def self.values_hash

        if !defined? @@values_hash
          @@values_hash = {}
          constants.each do |constant| 
            @@values_hash[class_eval(constant)] = constant
          end
        end

        @@values_hash
      end
    end

    # Reasons for creation for the AchievementSet model
    #
    class AchievementSetFor < Enumeration
      StarUsers   = 0
      TopShoppers = 1
    end

    # Edge case owner ids for the AchivementSet model
    #
    class AchievementSetOwner < Enumeration
      Automated = 0
    end

    # Names for the Action model
    #
    class ActionName < Enumeration
      Like  = 'like'
      Own   = 'own'
      Want  = 'want'
    end

    # Sources of landing at collections/new
    #
    class CollectionNewSource < Enumeration
      Error = 'error'
    end

    # Source of landing at collections/show
    #
    class CollectionShowSource < Enumeration
      Updated = 'collection_updated'
    end

    # Purpose for sending a user an email
    #
    class EmailPurpose < Enumeration
      Admin             = 99
      NewComment        = 0
      NewFollower       = 1
      NewAction         = 2
      TopShopper        = 4
      Welcome           = 10
      FriendCollection  = 11
      AnotherCollection = 12
      AnotherProduct    = 13
      AddItem           = 14
      AddFriend         = 15
      AddStore          = 16
      AddCollection     = 17
      FriendDigest      = 18
    end

    # Sources for the Following model
    #
    class FollowingSource < Enumeration
      Auto        = 0
      Manual      = 1
      Suggestion  = 2
    end

    # Services across the application for which health
    # reports are generated
    #
    class HealthReportService < Enumeration
      TopShopperUpdate        = 0
      AnotherCollectionPrompt = 1
      AnotherItemPrompt       = 2
      AddItemsPrompt          = 3
      AddFriendsPrompt        = 4
      AddStoresPrompt         = 5
      AddCollectionsPrompt    = 6
      FriendsDigest           = 7
    end

    # Sources of landing at the users/show route
    #
    class HomeShowSource < Enumeration
      UserCreateError = 'user_create_error'
      LoginError      = 'login_error'
      Logout          = 'logout'
    end

    # Sources of landing at products/new
    #
    class ProductNewSource < Enumeration
      Error = 'error'
    end

    # Source of landing at products/show
    #
    class ProductShowSource < Enumeration
      Updated = 'product_updated'
    end

    # Source for the creation of the Search model
    #
    class SearchSource < Enumeration
      New   = 0
      Edit  = 1
    end

    # Sources of creation for the Shopping model
    #
    class ShoppingSource < Enumeration
      User    = 0
      Product = 1
    end

    # Different sources of landing at the users/show route
    #
    class UserShowSource < Enumeration
      CollectionCreate      = 'collection_create'
      CollectionDeleted     = 'collection_deleted'
      HomeRedirect          = 'home_redirect'
      Login                 = 'login'
      UserCreate            = 'user_create'
      ProductCreate         = 'product_create'
      ProductDeleted        = 'product_deleted'
      ShoppingsCreate       = 'shoppings_create'
      ShoppingsCreateError  = 'shoppings_create_error'
    end

    # Hash tags for loading different views on
    # the users/show page
    #
    class UserShowHash < Enumeration
      Collections = 'looks'
      Owns        = 'owns'
      Wants       = 'wants'
    end

    # Different screens for the welcoem controller
    #
    class WelcomeFilter < Enumeration
      Learn   = 'intro'
      Stores  = 'stores'
      Follow  = 'follow'
      Friends = 'friends'
      Create  = 'create'
    end

    # Facebook OpenGraph objects
    #
    class OGObject < Enumeration
      Item    = "#{CONFIG[:fb_app_namespace]}:item" 
      Set     = "#{CONFIG[:fb_app_namespace]}:set" 
      Store   = "#{CONFIG[:fb_app_namespace]}:store" 
    end

    # Facebook OpenGraph Actions
    #
    class OGAction < Enumeration
      Add     = "#{CONFIG[:fb_app_namespace]}:add" 
      Use     = "#{CONFIG[:fb_app_namespace]}:use" 
    end

    # Facebook OpenGraph Properties
    #
    class OGProperty < Enumeration
      Length  = "#{CONFIG[:fb_app_namespace]}:length" 
    end

  end

end
