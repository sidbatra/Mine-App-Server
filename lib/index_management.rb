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
        Purchase.with_store.with_user.with_product_and_purchases.reindex(:batch_size => 1000,:batch_commit => false)
        Product.with_store.reindex(:batch_size => 1000,:batch_commit => false)
        User.with_followings.reindex(:batch_size => 500)
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
