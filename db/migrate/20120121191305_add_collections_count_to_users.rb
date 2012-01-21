class AddCollectionsCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :collections_count, :integer, :default => 0

    User.reset_column_information

    User.all(:include => :collections).each do |user|
      User.update_counters user.id, :collections_count => user.collections.length
      user.save!
    end
  end

  def self.down
    remove_column :users, :collections_count
  end
end
