Capistrano::Configuration.instance(:must_exist).load do

  namespace :deploy do
    desc "TESTING IT OUT"
    task :gum,:roles => [:web,:worker] do
      run "lsas"
      #a = capture "ls"
      #puts "RETURN - " + a.to_s
      #a = run "lsas" do |channel, stream, data|
      #  p channel
      #  p stream
      #  p "*** " + data
      #end
      #puts "RETURN - " + a.to_s
    end

    task :proxy do
      deploy.gum
    end
  end
end
