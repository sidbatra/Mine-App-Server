
namespace :deploy do

  ENVIRONMENTS  = ['production','staging']
  TYPES         = {:web => 'web',:proc => 'proc',
                    :cron => 'cron',:search => 'search'}


  module Deploy

    desc "Deploy a copy of the app on fresh instances"
    task :install do |e,args|
      setup_environment_variables
      connect_to_aws
      
      unless load_instances("0").zero?

        system("cap #{@environment} deploy:install") 

        Instance.update_all(
          @web_instances + @proc_instances + 
          @cron_instances + @search_instances,
          :tags => {:installed => '1'})
      end
    end # install

    desc "Update deployed copy of app"
    task :release do |e,args|
      setup_environment_variables
      connect_to_aws
      load_instances("1")

      system("cap #{@environment} deploy:release")
    end #release


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

    # Populate environment variables and module variables for instances.
    #
    # installed - String. ("0" or "1") signifying uninstalled or 
    #               installed instances. Default "1".
    #
    # returns - Integer. Total number of instances loaded into variables.
    #
    def self.load_instances(installed="1")
      @web_instances  = Instance.all(
                          :tags => {
                            :environment => @environment,
                            :installed => installed,
                            :type => TYPES[:web]},
                          :state => :running)

      @proc_instances = Instance.all(
                          :tags => {
                            :environment => @environment,
                            :installed => installed,
                            :type => TYPES[:proc]},
                          :state => :running)

      @cron_instances = Instance.all(
                          :tags => {
                            :environment => @environment,
                            :installed => installed,
                            :type => TYPES[:cron]},
                          :state => :running)

      @search_instances = Instance.all(
                          :tags => {
                            :environment => @environment,
                            :installed => installed,
                            :type => TYPES[:search]},
                          :state => :running)

      ENV['web_servers']  = @web_instances.map(&:dnsName).join(',')
      ENV['proc_servers'] = @proc_instances.map(&:dnsName).join(',')
      ENV['cron_servers'] = @cron_instances.map(&:dnsName).join(',')
      ENV['search_servers'] = @search_instances.map(&:dnsName).join(',')

      [@web_instances,@proc_instances,@cron_instances].map(&:length).sum
    end
  end #deploy module
end #deploy namespace


