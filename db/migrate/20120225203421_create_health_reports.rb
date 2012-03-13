class CreateHealthReports < ActiveRecord::Migration
  def self.up
    create_table :health_reports do |t|
      t.integer :service

      t.timestamps
    end

    add_index :health_reports, :service
  end

  def self.down
    drop_table :health_reports
  end
end
