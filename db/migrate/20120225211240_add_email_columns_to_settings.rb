class AddEmailColumnsToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :email_interaction, :boolean, :default => true
    add_column :settings, :email_influencer, :boolean, :default => true
    add_column :settings, :email_update, :boolean, :default => true
  end

  def self.down
    remove_column :settings, :email_update
    remove_column :settings, :email_influencer
    remove_column :settings, :email_interaction
  end
end
