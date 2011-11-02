module ProductsHelper

  # Format price or currency in general
  #
  def display_currency(amount)
    "$" + ("%.2f" % amount).chomp(".00")
  end

end
