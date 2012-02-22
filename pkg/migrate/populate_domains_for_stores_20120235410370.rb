class PopulateDomainsForStores < Brant::Migration

  require 'rake'

  def self.up
    if Rails.env != 'development'
      Rake::Task["stores:update:domains"].invoke
    end
  end

  def self.down
    if Rails.env != 'development'
    end
  end
end
