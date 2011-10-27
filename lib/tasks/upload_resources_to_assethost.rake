desc "Upload packaged javascripts and stylesheets to the asset host"

# A revision is appended to each updated resource file to
# prevent caching at the CDN's edge servers
#
task :upload_resources_to_assethost,:revision  do |e,args|

  require 'config/environment.rb'

  #revision = args.revision
  revision = CONFIG[:revision]

  Dir.new('public/stylesheets').each do |file|
    next unless file.scan('_packaged').present?

    AssetHost.store(
      "#{revision}/stylesheets/#{file}",
      open("public/stylesheets/#{file}"),
      "Content-Encoding" => 'gzip',
      "Expires" => 1.year.from_now.strftime("%a, %d %b %Y %H:%M:%S GMT"))
  end

  Dir.new('public/javascripts').each do |file|
    next unless file.scan('_packaged').present?

    AssetHost.store(
      "#{revision}/javascripts/#{file}",
      open("public/javascripts/#{file}"),
      "Content-Encoding" => 'gzip',
      "Expires" => 1.year.from_now.strftime("%a, %d %b %Y %H:%M:%S GMT"))
  end

  Dir.new('public/images').each do |file|
    next unless file.length > 2

    AssetHost.store(
      "#{revision}/images/#{file}",
      open("public/images/#{file}"),
      "Expires" => 1.year.from_now.strftime("%a, %d %b %Y %H:%M:%S GMT"))
  end

  Dir.new('public/type').each do |file|
    next unless file.length > 2

    AssetHost.store(
      "#{revision}/type/#{file}",
      open("public/type/#{file}"),
      "Expires" => 1.year.from_now.strftime("%a, %d %b %Y %H:%M:%S GMT"))
  end

  Dir.new('public/swfs').each do |file|
    next unless file.length > 2

    AssetHost.store(
      "#{revision}/swfs/#{file}",
      open("public/swfs/#{file}"),
      "Expires" => 1.year.from_now.strftime("%a, %d %b %Y %H:%M:%S GMT"))
  end

end
