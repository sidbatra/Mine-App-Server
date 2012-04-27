class RemoveTickerActionsFromDb < ActiveRecord::Migration
  def self.up
    drop_table :ticker_actions
  end

  def self.down
  end
end
