Capistrano::Configuration.instance(:must_exist).load do

  namespace :sphinx do 
    
    desc "Index and start the sphinx process"
    task :start, :roles => :search do
      rake "ts:index"
      rake "ts:start"
    end

    desc "Re-index sphinx"
    task :index, :roles => :search do
      rake "ts:index"
    end
  end

end
