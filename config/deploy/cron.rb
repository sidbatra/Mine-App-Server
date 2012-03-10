Capistrano::Configuration.instance(:must_exist).load do

  namespace :cron do
    
    desc "Update cron on web and proc servers"
    task :update_web_proc, :roles => [:web,:worker] do
      run "cd #{current_path} && RAILS_ENV=#{environment} "\
          "whenever -w -f config/whenever/web_proc.rb"
    end

    desc "Update cron on cron servers"
    task :update_cron, :roles => [:cron] do
      run "cd #{current_path} && RAILS_ENV=#{environment} "\
          "whenever -w -f config/whenever/cron.rb"
    end

  end

end

