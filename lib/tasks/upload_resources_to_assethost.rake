desc "Upload packaged javascripts and stylesheets to the asset host"

# A revision is appended to each updated resource file to
# prevent caching at the CDN's edge servers
#
task :upload_resources_to_assethost,:revision  do |e,args|

  require 'config/environment.rb'

  revision = args.revision

  Dir.new('public/images').each do |file|
    next unless file.length > 2

    AssetHost.store(
      "#{revision}/images/#{file}",
      open("public/images/#{file}"))
  end

  Dir.new('public/type').each do |file|
    next unless file.length > 2

    AssetHost.store(
      "#{revision}/type/#{file}",
      open("public/type/#{file}"))
  end

  Dir.new('public/swfs').each do |file|
    next unless file.length > 2

    AssetHost.store(
      "#{revision}/swfs/#{file}",
      open("public/swfs/#{file}"))
  end

  Dir.new('public/stylesheets').each do |file|
    next unless file.scan('_packaged').present?

    AssetHost.store(
      "#{revision}/stylesheets/#{file}",
      open("public/stylesheets/#{file}"))
  end

  Dir.new('public/javascripts').each do |file|
    next unless file.scan('_packaged').present?

    AssetHost.store(
      "#{revision}/javascripts/#{file}",
      open("public/javascripts/#{file}"))
  end

end
