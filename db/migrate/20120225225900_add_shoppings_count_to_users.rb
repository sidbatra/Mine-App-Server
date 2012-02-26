class AddShoppingsCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :shoppings_count, :integer, :default => 0

    columns = [:id,:shoppings_count,:updated_at,:created_at]
    values = []

    User.all(:include => :shoppings).each do |user|
      values << [user.id,user.shoppings.length,user.updated_at,user.created_at]
    end

    User.import(columns,values,
          {
            :validate => false,
            :timestamps => false,
            :on_duplicate_key_update => [:shoppings_count]})

    add_index :users, :shoppings_count
    add_index :users, :collections_count
    add_index :users, :products_count
    add_index :users, :followings_count
  end

  def self.down
    remove_column :users, :shoppings_count
    remove_index :users, :collections_count
    remove_index :users, :products_count
    remove_index :users, :followings_count
  end
end
