module DW

  # Set of classes and modules for accessing the Amazon Product
  # Advertising API
  #
  module AmazonProductInterface
    

    # Use the APA API to search products and get more
    # information about specific products
    #
    class AmazonProductSearch

      def self.configure
        index = rand CONFIG[:aws_associate_tags].length

        Amazon::Ecs.configure do |options|
          options[:associate_tag]     = CONFIG[:aws_associate_tags][index]
          options[:AWS_access_key_id] = CONFIG[:aws_associate_access_ids][index]
          options[:AWS_secret_key]    = CONFIG[:aws_associate_secret_keys][index]
        end
      end

      # Search amazon products matching a query with pagination.
      #
      # query - String. Find matching products for this query.
      # page  - Integer:1. Page of results
      # url_only - Boolean:false. Only return the url without running request.
      #
      # returns - Amazon::Ecs result object
      #
      def self.fetch_products(query,page=1,url_only=false)
        configure

        result = Amazon::Ecs.item_search(
                  query, {
                    :response_group => 'Images,Small',
                    :item_page => page,
                    :search_index => "All",
                    :url_only => url_only})

        unless url_only
          result = result.items.map{|item| AmazonProduct.new item}
        end

        result
      end

      # Retrieve multiple amazon products based on ids.
      #
      # ids. The String ids of Array of ids.
      #
      # returns - Amazon::Ecs result object.
      #
      def self.lookup_products(ids,url_only=false)
        configure

        ids = ids.join(",") if ids.is_a? Array
        result = Amazon::Ecs.item_lookup(ids,{
                    :response_group => 'Images,Small',
                    :url_only => url_only})

        unless url_only
          result = result.items.map{|item| AmazonProduct.new item}
        end

        result
      end

    end #amazon product search


    class AmazonProduct

      def initialize(item)
        @item = item
      end

      def small_image_url
        @item.get('SmallImage/URL')
      end

      def medium_image_url
        @item.get('MediumImage/URL')
      end

      def large_image_url
        @item.get('LargeImage/URL')
      end

      def page_url
        @item.get('DetailPageURL')
      end

      def product_id
        @item.get('ASIN')
      end

      def custom_product_id
        "AZ-#{product_id}"
      end

      def title
        @item.get('ItemAttributes/Title')
      end
    end

  end #amazon product interface

end #dw
