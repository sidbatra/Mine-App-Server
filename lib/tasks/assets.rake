namespace :assets do

  desc "Package and upload js,css and images to the asset host"
  task :deploy do |e,args|

    require 'config/environment.rb'

    revision    = CONFIG[:revision]
    asset_host  = ActionController::Base.asset_host.gsub("%d","")



    #--------- Attach asset_host to image and type references in css

    system "sed -i -e \"s/\\([\\\"']\\)\\/images/\\1#{asset_host.gsub("/","\\/")}"\
            "\\/images/g\" public/stylesheets/*.css"

    system "sed -i -e \"s/\\([\\\"']\\)\\/type/\\1#{"http://#{CONFIG[:host]}".gsub("/","\\/")}"\
            "\\/type/g\" public/stylesheets/*.css"


    #--------- Package it up
    Jammit.package!



    #--------- Replace originals with gzipped versions
    Dir.new('public/assets').each do |file| 
      next unless file.scan(/.gz$/).present?

      system("mv public/assets/#{file} public/assets/#{file[0..-4]}")
    end



    #--------- Upload packaged resources to asset host

    Dir.new('public/assets').each do |file|
      next unless file.length > 2

      AssetHost.store(
        "#{revision}/assets/#{file}",
        open("public/assets/#{file}"),
        "Content-Encoding" => 'gzip',
        "Expires" => 1.year.from_now.strftime("%a, %d %b %Y %H:%M:%S GMT"))
    end

    Dir.glob('public/images/**/*\.*').each do |file|
      AssetHost.store(
        file.gsub('public',revision),
        open(file),
        "Expires" => 1.year.from_now.strftime("%a, %d %b %Y %H:%M:%S GMT"))
    end

    #Dir.new('public/type').each do |file|
    #  next unless file.length > 2

    #  AssetHost.store(
    #    "#{revision}/type/#{file}",
    #    open("public/type/#{file}"),
    #    "Expires" => 1.year.from_now.strftime("%a, %d %b %Y %H:%M:%S GMT"))
    #end

    Dir.glob('public/swfs/**/*\.*').each do |file|
      AssetHost.store(
        file.gsub('public',revision),
        open(file),
        "Expires" => 1.year.from_now.strftime("%a, %d %b %Y %H:%M:%S GMT"))
    end


    #--------- Restore back to original state
    Dir.new('public/assets').each do |file| 
      next unless file.length > 2

      system("rm public/assets/#{file}")
    end

    system("rmdir public/assets")
    system("git checkout public/stylesheets/*.css")
  end

end #assets
