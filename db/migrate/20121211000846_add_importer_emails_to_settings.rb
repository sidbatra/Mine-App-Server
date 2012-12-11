class AddImporterEmailsToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :email_importer, :boolean, :default => true
  end

  def self.down
    remove_column :settings, :email_importer
  end
end
