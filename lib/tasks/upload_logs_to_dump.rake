desc "Upload app logs to the dump filesystem"


task :upload_logs_to_dump do |e,args|

  require 'config/environment.rb'

  prefix = [RAILS_ENV,CONFIG[:machine_id],Time.now.to_i].join('_')
  folder = Time.zone.now.strftime('%m-%d-%Y')

  ['access.log','error.log','production.log'].each do |file|

    path    = File.join(folder,[prefix,file].join('_'))
    source  = File.join(RAILS_ROOT,'log',file)

    response = Dump.store(path,open(source),:access => :private)

    if response.code == 200
      system("echo '' > #{source}")
    end
  end

end
