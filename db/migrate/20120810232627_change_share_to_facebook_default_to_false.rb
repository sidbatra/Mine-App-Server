class ChangeShareToFacebookDefaultToFalse < ActiveRecord::Migration
  def self.up
    change_column_default :settings, :share_to_facebook, false
  end

  def self.down
    change_column_default :settings, :share_to_facebook, true
  end
end
