class ChangeEndorsementToTextInProducts < ActiveRecord::Migration
  def self.up
    change_column :products, :endorsement, :text
    change_column :comments, :data, :text
  end

  def self.down
    change_column :products, :endorsement, :string
    change_column :comments, :data, :string
  end
end
