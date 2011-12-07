class MakeActionsPolymorphic < ActiveRecord::Migration
  def self.up
    add_column :actions, :actionable_type, :string
    add_column :actions, :actionable_id, :integer

    Action.all.each do |action|
      action.actionable_id = action.product_id
      action.actionable_type = 'Product'
      action.save!
    end

    remove_index :actions, [:product_id,:name,:user_id]
    remove_column :actions, :product_id

    add_index :actions, [:actionable_id,:actionable_type,:name,:user_id], :unique => true, :name => "index_actionable_name_user_id"
  end

  def self.down
    add_column :actions, :product_id, :integer

    Action.all.each do |action|
      action.product_id = action.actionable_id
      action.save!
    end

    remove_index :actions, :name => "index_actionable_name_user_id"

    remove_column :actions, :actionable_id
    remove_column :actions, :actionable_type

    add_index :actions, [:product_id,:name,:user_id], :unique => true
  end
end
