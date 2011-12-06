class ChangeThirdPartyIdToStringInContacts < ActiveRecord::Migration
  def self.up
    change_column :contacts, :third_party_id, :string
  end

  def self.down
    change_column :contacts, :third_party_id, :integer
  end
end
