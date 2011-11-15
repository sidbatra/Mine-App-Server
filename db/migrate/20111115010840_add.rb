class Add < ActiveRecord::Migration
  def self.up
    add_index :products, :handle

    Product.all.each{|p| p.generate_handle = true; p.save}
  end

  def self.down
  end
end
