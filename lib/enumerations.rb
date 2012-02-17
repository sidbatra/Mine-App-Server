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
      StarUser          = 3
      TopShopper        = 4
      Dormant           = 5
      OnToday           = 6
      CollectMore       = 7
      InviteMore        = 8
      NewBulkFollowers  = 9
    end

    # Sources for the Following model
    #
    class FollowingSource < Enumeration
      Auto        = 0
      Manual      = 1
      Suggestion  = 2
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
      CollectionCreate  = 'collection_create'
      CollectionDeleted = 'collection_deleted'
      HomeRedirect      = 'home_redirect'
      Login             = 'login'
      ProductCreate     = 'product_create'
      ProductDeleted    = 'product_deleted'
    end

    # Hash tags for loading different views on
    # the users/show page
    #
    class UserShowHash < Enumeration
      Collections = 'looks'
      Owns        = 'owns/all'
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
