class PopulateHandleForEveryStoreToCorrectInconsistencies < ActiveRecord::Migration
  def self.up
    Store.all.each do |store|
      store.generate_handle = true
      store.save
    end
  end

  def self.down
  end
end
