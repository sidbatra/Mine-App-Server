module DW

  # Set of classes to simuate enumerations
  #
  module Enumerations

    # Create enumeration classes that inherit from Enumeration.
    #
    # enums - Hash of hashes loaded from a YAML file. The outer hash
    #         keys are names of Enumeration classes and each inner hash
    #         key value pairs represent enumeration keys and their values.
    #
    # return - Boolean true
    #
    def self.populate(enums)
      enums.each do |name,enum|
        class_eval "#{name} = Class.new(Enumeration)"
        klass = const_get(name)

        enum.each do |key,value|
          value = value.is_a?(String) ? "\"#{value}\"" : value
          klass.class_eval("#{key} = #{value}")
        end
      end
      true
    end

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

      # Return value for a constant key.
      #
      # key - String. Name of the constant whose value
      #       is to be fetched
      #
      # Returns - Object. Value when key is found. nil otherwise.
      #
      def self.value_for(key)
        class_eval key.capitalize
      rescue NameError
        nil
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
    end #enumeration

  end #enumerations

end #dw
