module DW

  # Set of classes for handling storage across
  # the platform
  #
  module Storage

    # Open a connection to the AWS S3 service
    #
    AWS::S3::Base.establish_connection!(
      :access_key_id     => CONFIG[:aws_access_id],
      :secret_access_key => CONFIG[:aws_secret_key])


    # Provides static methods to interface with the
    # chosen FileSystem - S3 for now
    #
    class FileSystem
      
      # Bucket used for storing files
      #
      def self.bucket
        CONFIG[:s3_bucket]
      end

      # Converts a relative path to an full url on the filesystem
      # path - relative path
      #
      def self.url(path)
        #File.join(CONFIG[:edge_server].gsub("%d",rand(7).to_s),URI.encode(path))
        File.join(CONFIG[:edge_server]),URI.encode(path))
      end

      # Converts a relative path to a full path on the local filesystem
      #
      def self.local_path(path)
        RAILS_ROOT + "/" + path
      end

      # Stores a file onto the filesystem
      # path - relative path on the filesystem
      # stream - file stream object to upload the file without loading it 
      # fully in memory | also works if its a stream of bytes in memory
      # permissions - for the stored file, default :public_read
      #
      def self.store(path,stream,options={})
        options[:access] = :public_read if options[:access].nil?

        AWS::S3::S3Object.store(
          path,
          stream,
          self.bucket,
          options)
      end

      # Removes a file from the file filesystem
      # path - path of the file to be deleted
      #
      def self.delete(path) 
        AWS::S3::S3Object.delete(
          path,
          self.bucket)
      end

      # Fetches the value of a file at the given path
      # path - relative path of the file
      # - returns file contents in blob form
      #
      def self.value(path)
        AWS::S3::S3Object.value(
          path,
          self.bucket)
      end

      # Moves a file on the remote filesystem
      #
      def self.move(source,destination)
        AWS::S3::S3Object.rename(
          source,
          destination,
          self.bucket)
      end

    end #FileSystem

    
    # AssetHost stores assets used across the app
    # like images, css and js files
    #
    class AssetHost < FileSystem

      # Override the bucket used for storing files
      #
      def self.bucket
        CONFIG[:asset_bucket]
      end
    end

  end #storage

end #dw
