desc "Upload app logs to the dump filesystem"

ENV['RAILS_PATH'] = Dir.pwd
  
# Load rails config
CONFIG = YAML.load_file("config/config.yml")[ENV['RAILS_ENV']]
CONFIG[:machine_id] = `ec2-metadata -i`.chomp.split(" ").last

require 'rubygems'
require 'aws/s3'
require ENV['RAILS_PATH'] + '/lib/storage.rb'

task :upload_logs_to_dump do |e,args|


  prefix = [ENV['RAILS_ENV'],CONFIG[:machine_id],Time.now.to_i].join('_')
  folder = Time.now.strftime('%m-%d-%Y')

  ['access.log','error.log','production.log',
      'processor.rb.log','cron.log'].each do |file|

    path    = File.join(folder,[prefix,file].join('_'))
    source  = File.join(ENV['RAILS_PATH'],'log',file)

    next unless File.exists?(source) && File.size(source) != 0

    response = DW::Storage::Dump.store(path,open(source),:access => :private)

    if response.code == 200
      system("sudo chown manager:manager #{source}")
      system("sudo echo '' > #{source}")
    end
  end

end
