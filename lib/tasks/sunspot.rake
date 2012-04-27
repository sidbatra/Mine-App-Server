namespace :sunspot do

  namespace :solr do

    desc "Regenerate the search index"
    task :index => :environment do |e,args|
      include IndexManagement
      Index.regenerate
    end #index

  end #solr

end #sunspot
