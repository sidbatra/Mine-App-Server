module DW

  # Set of classes and methods for handling caching across the app
  #
  module CacheManagement

    # Wraps around Rails.cache for preventing development errors
    #
    class Cache

      # Wraps around rails cache fetch
      #
      def self.fetch(key,&block)
        if active?
          Rails.cache.fetch(key,&block)
        else
          yield if block_given?
        end
      end

      # Delete particular key from the cache
      #
      def self.delete(key)
        if active?
          Rails.cache.delete(key)
        else
          ActiveRecord::Base.logger.info "Expired : " + key
        end
      end

      # Wraps around rails cache clear
      #
      def self.clear
        if active?
          Rails.cache.clear
        else
          ActiveRecord::Base.logger.info "Expired : all"
        end
      end

      # Decides whether caching is on 
      #
      def self.active?
        RAILS_ENV != 'development' || ENV['CACHE_IN_DEV'] == 'true'
      end

    end #cache
  end #cache management

end #dw
