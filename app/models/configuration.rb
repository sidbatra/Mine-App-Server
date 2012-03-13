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
  end

end
