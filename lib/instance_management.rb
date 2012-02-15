module DW

  # Set of classes and methods for instace (server) management
  #
  module InstanceManagement

    require "AWS"
    
    # Manage tasks instance related tasks such as
    # fetching, creation, and deletion.
    #
    class Instance

      @states = {
                :pending      => "0",
                :running      => "16", 
                :shuttingdown => "32",
                :terminated   => "48",
                :stopping     => "64",
                :stopped      => "80"}

      @ec2 = AWS::EC2::Base.new(
              :access_key_id      => CONFIG[:aws_access_id],
              :secret_access_key  => CONFIG[:aws_secret_key])


      # Fetch all instances that match the provided
      # filtering options
      #
      def self.all(options={})
        instances = @ec2.describe_instances.reservationSet.item.map do |group| 
                      group.instancesSet.item
                    end.flatten

        if options[:state]
          instances = instances.select do |instance|
                        next unless instance.instanceState.code == 
                                      @states[options[:state]]
                        true
                      end
        end

        if tags_are_valid? options[:tags]

          instances = instances.select do |instance|
                        tags = instance.tagSet.item
                        next unless tags.length > 0 
                        
                        failed = false

                        tags.each do |tag|
                          key = tag.key.downcase.to_sym
                          failed = true if options[:tags][key] &&
                                            options[:tags][key] != tag.value
                        end

                        next if failed
                        true
                      end
        end

        instances
      end

      # Create fresh instances
      #
      def self.create(options={})
        response = @ec2.run_instances(options[:instances])
        instances = response.instancesSet.item
        sleep 3

        if tags_are_valid? options[:tags]
          @ec2.create_tags(
            :resource_id  => instances.map(&:instanceId),
            :tag          => options[:tags].map{|k,v| {k.to_s.capitalize => v}})
        end

        instances
      end

      # Destroy instances based on the tags provided
      #
      def self.destroy(options={})
        instances = all(options)
        instances = instances[0..options[:count]-1] if options[:count]

        @ec2.terminate_instances(:instance_id => instances.map(&:instanceId))

        instances
      end


      protected

      # Test validity of an array of tags associated with instances
      #
      def self.tags_are_valid?(tags)
        tags && tags.is_a?(Hash) && tags.length > 0
      end

    end #instance manager

  end #instance management

end #dw
