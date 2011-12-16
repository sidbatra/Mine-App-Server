class AddMoreLogosToStores < ActiveRecord::Migration
  def self.up
    dir = 'private/stores'

    Dir.new(dir).each do |file|
      next unless file.length > 2

      store = Store.find(file.split(".").first)

      if store
        store.is_processed = false
        store.save!
        store.host(File.join(dir,file)) 
      end
    end
  end

  def self.down
  end
end
