module EmailsHelper
  
  # Public. Whether the current rails environment
  # is development.
  #
  def is_dev?
    Rails.env.start_with? 'd'
  end
end
