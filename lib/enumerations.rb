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

    # Sources of creation for the Shopping model
    #
    class ShoppingSource < Enumeration
      User    = 0
      Product = 1
    end
  end

end
