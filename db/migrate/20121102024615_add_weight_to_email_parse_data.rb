class AddWeightToEmailParseData < ActiveRecord::Migration
  def self.up
    add_column :email_parse_data, :weight, :integer, :default => 0
  end

  def self.down
    remove_column :email_parse_data, :weight
  end
end
