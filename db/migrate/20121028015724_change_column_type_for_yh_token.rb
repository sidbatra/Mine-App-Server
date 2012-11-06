class ChangeColumnTypeForYhToken < ActiveRecord::Migration
  def self.up
    change_column :users,:yh_token,:text
  end

  def self.down
    change_column :users,:yh_token,:string
  end
end
