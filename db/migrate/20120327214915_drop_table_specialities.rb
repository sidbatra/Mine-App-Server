class DropTableSpecialities < ActiveRecord::Migration
  def self.up
    drop_table :specialties
  end

  def self.down
  end
end
