class RemovingEmailInteractionFromSettings < ActiveRecord::Migration
  def self.up
    remove_column :settings, :email_interaction
  end

  def self.down
  end
end
