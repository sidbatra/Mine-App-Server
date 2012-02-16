desc "Upload app logs to the dump filesystem"

ENV['RAILS_PATH'] = Dir.pwd

environment = ENV['RAILS_ENV']
environment ||= 'development'
  
# Load rails config
CONFIG = YAML.load_file("config/config.yml")[environment]
CONFIG[:machine_id] = `ec2-metadata -i`.chomp.split(" ").last

# Load logs config
files = YAML.load_file("config/logs.yml")

require 'rubygems'
require 'aws/s3'
require ENV['RAILS_PATH'] + '/lib/storage.rb'

task :upload_logs_to_dump do |e,args|

  prefix = [ENV['RAILS_ENV'],CONFIG[:machine_id]].join('_')
  folder = Time.now.strftime('%m-%d-%Y')

  files.each do |file|
    next unless File.exists?(file) && File.size(file) != 0

    path = File.join(folder,[prefix,File.basename(file)].join('_'))

    puts "Farming - " + file
    DW::Storage::Dump.store(path,open(file),:access => :private)
  end

  puts "Logs farmed for #{CONFIG[:machine_id]} at #{folder} with "\
        "prefix #{prefix}"
end
