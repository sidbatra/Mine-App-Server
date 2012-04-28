# Presenter for the Purchase model
#
class PurchasePresenter < BasePresenter
  presents :purchase
  delegate :thumbnail_url, :to => :purchase
  delegate :title, :to => :purchase

  # Relative path for the purchase
  #
  def path(source)
    h.purchase_path purchase.user.handle,purchase.handle,:src => source
  end
  
  # Absolute path for the purchase
  # 
  def url(source)
    h.purchase_url purchase.user.handle,purchase.handle,:src => source
  end

  # Description message for the purchase used in 
  # og description tag
  #
  def description
    purchase.store && purchase.store.is_approved ? 
      "Bought at #{purchase.store.name}" : ''
  end


end
