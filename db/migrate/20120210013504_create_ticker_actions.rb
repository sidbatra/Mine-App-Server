class CreateTickerActions < ActiveRecord::Migration
  def self.up
    create_table :ticker_actions do |t|
      t.string  :og_action_id
      t.string  :og_action_type
      t.integer :ticker_actionable_id
      t.string  :ticker_actionable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :ticker_actions
  end
end
