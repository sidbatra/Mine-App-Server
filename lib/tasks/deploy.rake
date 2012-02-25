
namespace :deploy do

  ENVIRONMENTS  = ['production','staging']
  TYPES         = {:web => 'web',:proc => 'proc',:cron => 'cron'}


  module Deploy

    desc "Deploy a copy of the app on fresh instances"
    task :install do |e,args|
      setup_environment_variables
      connect_to_aws
      load_instances

      system("cap #{@environment} deploy:install")

      Instance.update_all(
        @web_instances + @proc_instances + @cron_instances,
        :tags => {:installed => '1'})
    end

    desc "Update deployed copy of app"
    task :release do |e,args|
      setup_environment_variables
      connect_to_aws
      load_instances

      system("cap #{@environment} deploy:release")
    end


    # Validate and setup environment variables
    #
    def self.setup_environment_variables
      require 'lib/aws_management'

      include DW
      include AWSManagement

      @environment  = ENV['env']

      raise IOError,"" unless @environment &&
                        ENVIRONMENTS.include?(@environment) 

    rescue
      puts "Usage:\nrake deploy:{install,release} "\
            "env={production,staging}"
      exit
    end

    # Open a connection to AWS
    #
    def self.connect_to_aws
      config = YAML.load_file("config/config.yml")[@environment]
      AWSConnection.establish(config[:aws_access_id],config[:aws_secret_key])
    end

    # Populate instances and populate environment variables
    #
    def self.load_instances
      @web_instances  = Instance.all(
                          :tags => {
                            :environment => @environment,
                            :type => TYPES[:web]},
                          :state => :running)

      @proc_instances = Instance.all(
                          :tags => {
                            :environment => @environment,
                            :type => TYPES[:proc]},
                          :state => :running)

      @cron_instances = Instance.all(
                          :tags => {
                            :environment => @environment,
                            :type => TYPES[:cron]},
                          :state => :running)

      ENV['web_servers']  = @web_instances.map(&:dnsName).join(',')
      ENV['proc_servers'] = @proc_instances.map(&:dnsName).join(',')
      ENV['cron_servers'] = @cron_instances.map(&:dnsName).join(',')
    end
  end #deploy module
end #deploy namespace


