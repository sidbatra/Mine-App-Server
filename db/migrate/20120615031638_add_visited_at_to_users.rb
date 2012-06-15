class AddVisitedAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :visited_at, :datetime

    columns = [:id,:visited_at]
    values = []

    User.updated(30.days.ago).
      all(:include => [:searches,:likes,:comments,:purchases]).each do |user|

      values << [user.id,[user.created_at,
                          user.searches.map(&:created_at),
                          user.likes.map(&:created_at),
                          user.comments.map(&:created_at),
                          user.purchases.map(&:created_at)].flatten.max]
    end

    User.import(
          columns,
          values,{
            :validate => false,
            :timestamps => false,
            :on_duplicate_key_update => [:visited_at]})

    add_index :users, :visited_at
  end

  def self.down
    remove_column :users, :visited_at
  end
end
