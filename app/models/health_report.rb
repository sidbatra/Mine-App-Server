class HealthReport < ActiveRecord::Base

  #----------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------
  validates_inclusion_of  :service, :in => HealthReportService.values

  #----------------------------------------------------------------------
  # Named scopes
  #----------------------------------------------------------------------
  named_scope :for_service, lambda {|service| {
                              :conditions => {:service => service}}}

  #----------------------------------------------------------------------
  # Class methods
  #----------------------------------------------------------------------

  # Factory method for creating a health report.
  #
  def self.add(service)
    create!(
      :service => service)
  end
end
