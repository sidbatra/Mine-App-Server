module DW

  # Set of classes and methods for maintaining & creating the search index
  #
  module IndexManagement

    # Provides methods for modifying and creating the search index
    #
    class Index
      
      # Regenerate the search index
      #
      def self.regenerate
        Purchase.with_store.reindex
      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      # Optimize an existing index
      #
      def self.optimize
        Sunspot.optimize
      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

    end #index management

  end #index

end #dw
