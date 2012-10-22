module DW

  # Set of classes and modules for accessing the Amazon Product
  # Advertising API
  #
  module AmazonProductInterface
    
    # Setup options for accessing the api
    #
    Amazon::Ecs.configure do |options|
      options[:associate_tag]     = CONFIG[:aws_associate_tag]
      options[:AWS_access_key_id] = CONFIG[:aws_access_id]
      options[:AWS_secret_key]    = CONFIG[:aws_secret_key]
    end

    # Use the APA API to search products and get more
    # information about specific products
    #
    class AmazonProductSearch

      # Search amazon products matching a query with pagination.
      #
      # query - String. Find matching products for this query.
      # page  - Integer:1. Page of results
      # url_only - Boolean:false. Only return the url without running request.
      #
      # returns - Amazon::Ecs result object
      #
      def self.fetch_products(query,page=1,url_only=false)
        result = Amazon::Ecs.item_search(
                  query, {
                    :response_group => 'Images,Small',
                    :item_page => page,
                    :search_index => "All",
                    :url_only => url_only})
      end

      # Retrieve multiple amazon products based on ids.
      #
      # ids. The String ids of Array of ids.
      #
      # returns - Amazon::Ecs result object.
      #
      def self.lookup_products(ids)
        ids = ids.join(",") if ids.is_a? Array
        result = Amazon::Ecs.item_lookup(ids,{
                    :response_group => 'Images,Small'})
      end

    end #amazon product search

  end #amazon product interface

end #dw
