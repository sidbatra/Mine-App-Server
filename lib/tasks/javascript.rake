namespace :js do

  namespace :dump do

    desc "Dump javascript enumerations into a separate file"
    task :enums do |e,args|
      enums = YAML.load_file("#{RAILS_ROOT}/config/enumerations.yml")
      file = File.open("#{RAILS_ROOT}/public/javascripts/enumerations.js","w")

      file.puts "// Auto-generated via \"rake js:dump:enums\"\n"\
                "// \n"\
                "// IMP: Do not edit directly. Edit config/enumerations.yml \n"\
                "// and rerun \"rake js:dump:enums\"\n"\
                "// \n"

      enums[:javascript].
        sort{|a,b| a[0] <=> b[0]}.
        each do |klass,enum|

        file.puts "\nDenwen.#{klass} = {"
        
        enum.each_with_index do |(key,value),i|
          file.puts "#{key}: " + 
                  (value.is_a?(String) ? "\"#{value}\"" : "#{value}") +
                  (i != enum.length-1 ? ",\n" : "")
        end

        file.puts "}\n"
      end

      file.close
    end #enums

    desc "Dump javascript config into a separate file"
    task :config do |e,args|
      enums = YAML.load_file("#{RAILS_ROOT}/config/config.yml")['javascript']
      file = File.open("#{RAILS_ROOT}/public/javascripts/config.js","w")

      file.puts "// Auto-generated via \"rake js:dump:config\"\n"\
                "// \n"\
                "// IMP: Do not edit directly. Edit config/config.yml \n"\
                "// and rerun \"rake js:dump:config\"\n"\
                "// \n"

      file.puts "CONFIG = {"
        
      enums.
        sort{|a,b| a[0].to_s <=> b[0].to_s}.
        each_with_index do |(key,value),i|

        file.puts "'#{key.to_s}' : " + 
                (value.is_a?(String) ? "\"#{value}\"" : "#{value}") +
                (i != enums.length-1 ? ",\n" : "")
      end

      file.puts "}\n"

      file.close
    end #config

  end #dump

end #enumerations
