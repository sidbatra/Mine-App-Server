class AddImagesToStores < ActiveRecord::Migration
  def self.up
    Store.update_all(:is_processed => false)

    dir = 'private/stores'

    Dir.new(dir).each do |file|
      next unless file.length > 2

      store = Store.find(file.split(".").first)
      store.host(File.join(dir,file)) if store
    end
  end

  def self.down
  end
end
