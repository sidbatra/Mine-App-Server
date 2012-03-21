# Observe events on the Ticker Action model
#
class TickerActionObserver < ActiveRecord::Observer

  # Delete facebook stories after a ticker action is destroyed
  # as a result of product, collection or user deletion 
  #
  def after_destroy(ticker_action)
    ProcessingQueue.push(
      DistributionManager,
      :delete_story,
      ticker_action.og_action_id,
      ticker_action.user.access_token)
  end

end
