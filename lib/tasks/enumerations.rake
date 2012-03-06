namespace :enums do

  namespace :dump do

    desc "Dump javascript enumerations into a separate file"
    task :js do |e,args|
      enums = YAML.load_file("#{RAILS_ROOT}/config/enumerations.yml")
      file = File.open("#{RAILS_ROOT}/public/javascripts/enumerations.js","w")

      file.puts "// Auto-generated via \"rake enums:dump:js\"\n"\
                "// \n"\
                "// IMP: Do not edit directly. Edit config/enumerations.yml \n"\
                "// and rerun \"rake enums:dump:js\"\n"\
                "// \n"

      enums[:javascript].each do |klass,enum|
        file.puts "\nDenwen.#{klass} = {"
        
        enum.each_with_index do |(key,value),i|
          file.puts "#{key}: " + 
                  (value.is_a?(String) ? "\"#{value}\"" : "#{value}") +
                  (i != enum.length-1 ? ",\n" : "")
        end

        file.puts "}\n"
      end

      file.close
    end

  end #dump

end #enumerations
