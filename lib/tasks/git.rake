namespace :git do

  namespace :merge do

    desc "Merge develop into master with tagging"
    task :master do |e,args|
      message = ENV['message']

      unless message.present?
        puts "Usuage - rake git:merge:master message='Tag message'" 
        exit
      end

      system "git pull"
      system "git merge --no-ff origin/develop"
      system "git push"

      version = YAML.load_file("config/config.yml")['production'][:version]

      system "git tag -a #{version} -m \"#{message}\""
      system "git push origin #{version}"
    end #master

  end #merge

end #git
