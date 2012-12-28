module EmailsHelper
  
  # Public. Whether the current rails environment
  # is development.
  #
  def is_dev?
    Rails.env.start_with? 'd'
  end

  def days_to_email_import
    days = (7 - Time.zone.now.wday + 3) % 7
    days = 7 if days.zero?
    days
  end
end
