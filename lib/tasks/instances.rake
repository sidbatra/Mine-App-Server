require 'lib/aws_management'

include DW
include AWSManagement

namespace :instances do

  IMAGE_ID           = 'ami-914595f8'
  INSTANCE_TYPE      = 't1.micro'
  AVAILABILITY_ZONE  = 'us-east-1b'
  SECURITY_GROUP     = 'sg-7c5fca15'
  TYPES              = {:web => 'web',:proc => 'proc'}
  ENVIRONMENTS       = ['production','staging']
  SPECS_REGEX        = "^(((#{TYPES.values.join('|')}){1}:(\\d)+)[,]{0,1})+$"


  module Instances

    desc "Launch fresh instances"
    task :create do |e,args|
      setup_environment_variables
      connect_to_aws

      # Launch instances independently for each spec
      #
      @specs.split(',').each do |spec|
        type,count = spec.split(':')
        instances = Instance.create(
                      :instances => {
                        :image_id => IMAGE_ID,
                        :min_count => count,
                        :max_count => count,
                        :instance_type => INSTANCE_TYPE,
                        :availability_zone => AVAILABILITY_ZONE,
                        :security_group => SECURITY_GROUP},
                      :tags => {
                        :environment => @environment,
                        :type => type,
                        :installed => '0',
                        :name => "Closet #{@environment.capitalize} "\
                                  "#{type.capitalize}"})

        if type == TYPES[:web]
          load_balancer = LoadBalancer.find(:matching => @environment)
          load_balancer.attach(instances.map(&:instanceId)) if load_balancer
        end
      end
    end

    desc "Destroy running instances"
    task :destroy do |e,args|
      setup_environment_variables
      connect_to_aws

      # Destroy instances independently for each spec
      #
      @specs.split(',').each do |spec|
        type,count = spec.split(':')
        instances = Instance.destroy_all(
                      :tags => {
                        :environment => @environment,
                        :type => type},
                      :state => :running,
                      :count => 1)

        if type == TYPES[:web]
          load_balancer = LoadBalancer.find(:matching => @environment)
          load_balancer.dettach(instances.map(&:instanceId)) if load_balancer
        end
      end
    end


    # Validate and setup environment variables
    #
    def setup_environment_variables
      @specs        = ENV['specs']
      @environment  = ENV['env']

      raise IOError,"" unless @specs && 
                        @environment &&
                        ENVIRONMENTS.include?(@environment) &&
                        @specs.match(Regexp.new(SPECS_REGEX))

    rescue
      puts "Usage:\nrake instances:{create,destroy} "\
            "specs=[{web,proc}:count](,) "\
            "env={production,staging}"
      exit
    end

    # Open a connection to AWS
    #
    def connect_to_aws
      config = YAML.load_file("config/config.yml")[@environment]
      AWSConnection.establish(config[:aws_access_id],config[:aws_secret_key])
    end

  end #instances module

end #instances namespace
