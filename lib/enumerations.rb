module DW

  # Set of classes to simuate enumerations
  #
  module Enumerations

    # Base class for all enumerations
    #
    class Enumeration
      
      # Return a range starting at 0 and till the
      # total length of constants in the class. This is useful
      # if the Enumeration holds types that map to ActiveRecord
      # columns that require validation for inclusion
      #
      def self.range
        (0..constants.length-1)
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
