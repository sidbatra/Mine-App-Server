class Configuration < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_inclusion_of :variable, :in => ConfigurationVariable.values
  validates_presence_of :value

  #----------------------------------------------------------------------
  # Attributes
  #----------------------------------------------------------------------
  attr_accessible :variable,:value

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Read the value of a variable from the database
  #
  # variable - Integer. name of the variable.
  #
  # returns - String. value of the variable. nil if not found
  #
  def self.read(variable)
    find_by_variable(variable).value rescue nil
  end

  # Create or update the value of a variable in the database
  #
  # variable - Integer. Name of the variable to be written.
  # value - String. Value of the variable to be set.
  #
  # returns - Configuration. Updated or created configuration model.
  #
  def self.write(variable,value)
    config = find_or_initialize_by_variable(variable)
    config.value = value
    config.save!
    config
  end

end
