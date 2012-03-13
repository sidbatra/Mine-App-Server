class RemoveSpacesFromAllProductTitles < ActiveRecord::Migration
  def self.up
    columns = [:id,:title]
    values  = []

    Product.all.each do |product|
      values << [product.id,product.title.strip]
    end

    Product.import(
      columns,
      values,
      {
        :validate => false,
        :timestamps => false,
        :on_duplicate_key_update => [:title]})
  end

  def self.down
  end
end
