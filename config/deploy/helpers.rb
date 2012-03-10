Capistrano::Configuration.instance(:must_exist).load do

    # Run rake tasks on remote servers or local deploy server..
    #
    # name - String. Name of the rake task to be run. 
    # options - Hash. Default = {},Valid options:
    #   local - Boolean. Run rake task in remote app folder or
    #             local deploy folder. Default - false
    #   sudo - Boolean. Run with sudo or not. Default - false.
    #
    # returns - Boolean. true.
    #
    def rake(name,options={})
      command = "#{options[:local] ? "run_locally" : "run"} \""\
                "cd #{options[:local] ? Dir.pwd : current_path} && "\
                "#{options[:sudo] ? "sudo" :""} "\
                "rake #{name} RAILS_ENV=#{environment}\"" 
      eval command
      true
    end
end
