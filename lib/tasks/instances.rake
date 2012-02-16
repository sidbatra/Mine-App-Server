require 'lib/aws_management'

include DW
include AWSManagement


namespace :instances do

  desc "Launch fresh instances"
  task :create do |e,args|
    setup_environment_variables
    connect_to_aws
  end

  desc "Destroy running instances"
  task :destroy do |e,args|
  end

  # Validate and setup environment variables
  #
  def setup_environment_variables
    @specs        = ENV['specs']
    @environment  = ENV['env']

    unless @specs && @environment
      puts "Usage:\nrake instances:{create,destroy} "\
            "specs=[web,proc]:[count] "\
            "env={production,staging}"
      exit
    end
  end

  # Open a connection to AWS
  #
  def connect_to_aws
    config = YAML.load_file("config/config.yml")[@environment]
    AWSConnection.establish(config[:aws_access_id],config[:aws_secret_key])
  end

end
