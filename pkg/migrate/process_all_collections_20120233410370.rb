class ProcessAllCollections < Brant::Migration

  require 'config/environment'

  def self.up
    if Rails.env != 'development'
      Collection.with_products.all.each{|c| c.process}
    end
  end

  def self.down
    if Rails.env != 'development'
      Collection.update_all(:is_processed => false)
    end
  end
end
