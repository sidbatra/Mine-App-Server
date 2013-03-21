
namespace :instances do

  IMAGE_IDS          = {'32' => 'ami-343be45d','64' => 'ami-b6af37df'}
  INSTANCE_SIZES     = {:micro => 't1.micro',:medium => 'm1.medium',:small => 'm1.small'}
  AVAILABILITY_ZONE  = 'us-east-1b'
  SECURITY_GROUP     = 'sg-7c5fca15'
  TYPES              = {:web => 'web',:proc => 'proc',:cron => 'cron',
                        :search => 'search', :generic => 'generic', 
                        :crawler => 'crawler'}
  REPOS              = {'web' => 'app','proc' => 'app','cron' => 'app',
                        'search' => 'app', 'generic' => 'none',
                        'crawler' => 'crawler'}
  SEARCH_IPS         = {'staging' => '23.21.154.238', 
                        'production' => '23.21.152.127'}
  CRAWLER_IPS        = {'staging' => '23.23.124.176',
                        'production' => '23.23.124.178'}
  ENVIRONMENTS       = ['production','staging','development']
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
                        :image_id => IMAGE_IDS[@os],
                        :min_count => count,
                        :max_count => count,
                        :instance_type => INSTANCE_SIZES[@size],
                        :availability_zone => AVAILABILITY_ZONE,
                        :security_group => SECURITY_GROUP},
                      :tags => {
                        :environment => @environment,
                        :type => type,
                        :repo => REPOS[type],
                        :installed => '0',
                        :name => "#{@config[:name]} "\
                                  "#{@environment.capitalize} "\
                                  "#{type.capitalize}"})

        if type == TYPES[:web]
          load_balancer = LoadBalancer.find(:matching => @environment)
          load_balancer.attach(instances.map(&:instanceId)) if load_balancer
        end

        if type == TYPES[:search]
          instance = instances.last
          instance.apply_elastic_ip(SEARCH_IPS[@environment])
        end

        if type == TYPES[:crawler]
          instance = instances.last
          instance.apply_elastic_ip(CRAWLER_IPS[@environment])
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
                      :count => count.to_i)

        if type == TYPES[:web]
          load_balancer = LoadBalancer.find(:matching => @environment)
          load_balancer.dettach(instances.map(&:instanceId)) if load_balancer
        end
      end
    end


    # Validate and setup environment variables
    #
    def self.setup_environment_variables
      require 'lib/aws_management'

      include DW
      include AWSManagement

      @specs        = ENV['specs']
      @environment  = ENV['env']
      @os           = ENV['os'] ? ENV['os'] : '64'
      @size         = ENV['size'] ? ENV['size'].to_sym : :micro

      raise IOError,"" unless @specs && 
                        @environment &&
                        IMAGE_IDS.keys.include?(@os) &&
                        ENVIRONMENTS.include?(@environment) &&
                        INSTANCE_SIZES.include?(@size) &&
                        @specs.match(Regexp.new(SPECS_REGEX))

    rescue
      puts "Usage:\nrake instances:{create,destroy} "\
            "specs=[{#{TYPES.keys.join(",")}}:count](,) "\
            "env={#{ENVIRONMENTS.join(",")}} "\
            "os={32,64} "\
            "size={#{INSTANCE_SIZES.keys.join(',')}}"
      exit
    end

    # Open a connection to AWS
    #
    def self.connect_to_aws
      @config = YAML.load_file("config/config.yml")[@environment]
      AWSConnection.establish(@config[:aws_access_id],@config[:aws_secret_key])
    end

  end #instances module

end #instances namespace
