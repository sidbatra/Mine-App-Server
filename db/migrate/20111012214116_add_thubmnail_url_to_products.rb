class AddThubmnailUrlToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :thumb_url, :string
  end

  def self.down
    remove_column :products, :thumb_url
  end
end
