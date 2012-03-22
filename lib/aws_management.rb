module DW

  # Set of classes and methods for interfacing with AWS
  #
  module AWSManagement

    require "AWS"

    # Maintains connections to AWS services
    #
    class AWSConnection
      
      # Open a connection to ec2 and elb
      #
      def self.establish(access_key_id,secret_access_key)
        @@ec2 ||= AWS::EC2::Base.new(
                    :access_key_id      => access_key_id,
                    :secret_access_key  => secret_access_key)
      
        @@elb ||= AWS::ELB::Base.new(
                    :access_key_id      => access_key_id,
                    :secret_access_key  => secret_access_key)

        true
      end

      # Retrieve the ec2 connection object
      #
      def self.ec2
        @@ec2
      end

      # Retrieve the elb connection object
      def self.elb
        @@elb
      end
    end


    # Mixin module with methods to interface with AWS response objects
    # that contain a param hash
    #
    module AWSObjectInterface

      module ClassMethods

        # Create class object from params hash. Object can be an array
        # of params hashs or a single param hash
        #
        def instantize(object)
          object.is_a?(Array) ? object.map{|o| new(o)} : new(object)
        end

      end
      
      # Create a class object from a params hash making all 
      # keys of the params hash available as instance variables
      #
      def initialize(params)
        params.each do |k,v|
          self.instance_variable_set("@#{k}",v)
          self.class.send(
            :define_method,
            k,
            proc{self.instance_variable_get("@#{k}")})
        end

        tags = {}

        self.tagSet.item.each do |tag|
          tags[tag.key.downcase.to_sym] = tag.value
        end if params['tagSet'] && self.tagSet.item

        self.instance_variable_set("@tags",tags)
        self.class.send(
          :define_method,
          "tags",
          proc{self.instance_variable_get("@tags")})
      end

      # Explicitly mix in class methods 
      #
      def self.included(base)
        base.extend ClassMethods
      end
    end

    
    # Represents an Instance on AWS. It's used 
    # perform tasks such as fetching, creation, and deletion.
    #
    class Instance

      include AWSObjectInterface

      @@states = {
                :pending      => "pending",
                :running      => "running", 
                :shuttingdown => "shutting-down",
                :terminated   => "terminated",
                :stopping     => "stopping",
                :stopped      => "stopped"}

      # Fetch all instances that match the provided
      # filtering options
      #
      def self.all(options={})
        instances = AWSConnection.ec2.describe_instances.
                      reservationSet.item.map do |group| 
                        group.instancesSet.item
                    end.flatten

        instances = instantize(instances)

        if options[:instance_ids]
          instances = instances.select do |instance|
                        next unless options[:instance_ids].
                                      include?(instance.instanceId)
                        true
                      end
        end

        if options[:state]
          instances = instances.select do |instance|
                        next unless instance.instanceState.name == 
                                      @@states[options[:state]]
                        true
                      end
        end

        if options[:age]
          current_time = Time.now.utc
          instances = instances.select do |instance|
                        next unless current_time - 
                                      Time.parse(instance.launchTime) >
                                      options[:age]
                        true
                      end
        end

        if tags_are_valid? options[:tags]

          instances = instances.select do |instance|
                        failed = false

                        options[:tags].each do |k,v|
                          failed = true if instance.tags[k] != v
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
        response = AWSConnection.ec2.run_instances(options[:instances])
        instances = instantize(response.instancesSet.item)
        sleep 5

        update_all(instances,options)

        instances
      end

      # Update all given instances with the given options
      #
      def self.update_all(instances,options={})

        if tags_are_valid? options[:tags]
          AWSConnection.ec2.create_tags(
            :resource_id  => instances.map(&:instanceId),
            :tag          => options[:tags].map{|k,v| {k.to_s.capitalize => v}})
        end

        instances
      end

      # Destroy instances based on the tags provided
      #
      def self.destroy_all(options={})
        instances = all(options)
        instances = instances[0..options[:count]-1] if options[:count]

        AWSConnection.ec2.terminate_instances(
          :instance_id => instances.map(&:instanceId))

        instances
      end


      # Apply an elastic ip address to the instance.
      #
      # ip - String. Elastic ip address.
      #
      # returns - Boolean. true.
      #
      def apply_elastic_ip(ip)
        AWSConnection.ec2.associate_address(
          :instance_id => self.instanceId,
          :public_ip => ip)
        true
      end


      protected

      # Test validity of an array of tags associated with instances
      #
      def self.tags_are_valid?(tags)
        tags && tags.is_a?(Hash) && tags.length > 0
      end

    end #Instance

    
    # Represents a Load Balancer on AWS. It's used 
    # perform tasks such as fetching, creation, and deletion.
    #
    class LoadBalancer

      include AWSObjectInterface


      # Fetch all load balancers matching the given options
      #
      def self.all(options={})
        balancers = AWSConnection.elb.describe_load_balancers.
                      DescribeLoadBalancersResult.
                      LoadBalancerDescriptions.
                      member

        if options[:matching]
          balancers = balancers.select do |balancer|
                        balancer.LoadBalancerName.match(options[:matching])
                      end
        end

        instantize(balancers)
      end

      # Fetch a specific load balancer using the given options
      #
      def self.find(options={})
        balancers = all(options)
        balancers.length > 0 ? balancers.first : nil
      end


      # Add given instance ids to the load balancer
      #
      def attach(instance_ids)
        instance_ids = [instance_ids] if instance_ids.is_a? String

        AWSConnection.elb.register_instances_with_load_balancer(
          :instances          => instance_ids,
          :load_balancer_name => self.LoadBalancerName)
      end

      # Remove given instance ids from the load balancer
      #
      def dettach(instance_ids)
        instance_ids = [instance_ids] if instance_ids.is_a? String

        AWSConnection.elb.deregister_instances_from_load_balancer(
          :instances          => instance_ids,
          :load_balancer_name => self.LoadBalancerName)
      end

    end

  end #LoadBalancer

end #dw
