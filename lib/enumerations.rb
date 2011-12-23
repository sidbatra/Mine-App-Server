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

    # Types of sources for the Shopping model
    #
    class ShoppingSource < Enumeration
      User    = 0
      Product = 1
    end
  end

end
