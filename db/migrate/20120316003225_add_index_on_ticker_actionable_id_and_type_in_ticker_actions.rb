class AddIndexOnTickerActionableIdAndTypeInTickerActions < ActiveRecord::Migration
  def self.up
    add_index :ticker_actions, [:ticker_actionable_id,:ticker_actionable_type], :name => "index_ticker_actions_on_ticker_actionable_id_and_type"
  end

  def self.down
    remove_index :ticker_actions, [:ticker_actionable_id,:ticker_actionable_type]
  end
end
