desc "Rename assests incoporating the name of the given revision"


task :rename_resources_for_deployment,:revision  do |e,args|

  require 'config/environment.rb'

  revision    = args.revision
  asset_host  = ActionController::Base.asset_host

  system "sed -i -e \"s/'\\/images/'#{asset_host.gsub("/","\\/")}"\
          "\\/images/g\" public/javascripts/*.js public/stylesheets/*.css"

  #system "sed -i -e \"s/'\\/type/'#{asset_host.gsub("/","\\/")}"\
  #        "\\/type/g\" public/stylesheets/*.css"

  system "sed -i -e \"s/'\\/type/'#{http://felvy.com}"\
          "\\/type/g\" public/stylesheets/*.css"

  system "sed -i -e \"s/'\\/swfs/'#{asset_host.gsub("/","\\/")}"\
          "\\/swfs/g\" public/javascripts/*.js"

end
