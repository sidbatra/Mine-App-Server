module DW

  # Set of classes and methods for handling caching across the app
  #
  module CacheManagement

    # Wraps around Rails.cache for preventing devleopment errors
    #
    class Cache

      # Wraps around rails cache fetch
      #
      def self.fetch(key,&block)
        if RAILS_ENV != 'development' || ENV['CACHE_IN_DEV'] == 'true'
          Rails.cache.fetch(key,&block)
        else
          yield if block_given?
        end
      end

      # Delete particular key from the cache
      #
      def self.delete(key)
        Rails.cache.delete(key)
      end

      # Wraps around rails cache clear
      #
      def self.clear
        Rails.cache.clear
      end

    end #cache
  end #cache management

end #dw
