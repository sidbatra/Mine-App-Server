namespace :enums do

  namespace :dump do

    desc "Dump javascript enumerations into a separate file"
    task :js do |e,args|
      enums = YAML.load_file("#{RAILS_ROOT}/config/enumerations.yml")

      enums[:javascript].each do |klass,enum|
        puts "Denwen.#{klass} = {"
        
        text = []

        enum.each do |key,value|
          text << "#{key}: " + 
                  (value.is_a?(String) ? "\"#{value}\"" : "#{value}")
        end

        puts text.join(",\n")

        puts "}"
      end
    end

  end #dump

end #enumerations
