class ChangeDefaultValuesForShareSettings < ActiveRecord::Migration
  def self.up
    change_column_default :settings, :share_to_facebook, true 
    change_column_default :settings, :share_to_twitter, true 
  end

  def self.down
    change_column_default :settings, :share_to_facebook, false
    change_column_default :settings, :share_to_twitter, false
  end
end
