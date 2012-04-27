namespace :products do

  namespace :import do

    desc "Create products from crawled store pages"
    task :crawled => :environment do |e,args|
    begin
      dir = ENV['dir']

      unless dir
        puts "Usage:\n rake products:import:crawled dir=DIR_PATH"
        exit
      end

      columns = [:title,:description,:source_url,:orig_image_url,
                  :orig_image_url_hash,:store_id]

      values  = []

      Dir.glob("#{dir}/*").each do |file_name|
        file = File.open(file_name) 

        file.each do |line|
          product = line.chomp.split("\t")

          source_url          = product[0]
          title               = product[1]
          orig_image_url      = product[2]
          orig_image_url_hash = Digest::SHA1.hexdigest(orig_image_url)
          store_id            = product[3]
          description         = product[4]

          values << [title,description,source_url,orig_image_url,
                      orig_image_url_hash,store_id]
        end#file
      end#Dir

      Product.import columns,values,{:validate => false}
      products = Product.find_all_by_is_processed(false)

      products.each do |product|
        ProcessingQueue.push(
          ProductDelayedObserver,
          :after_create,
          product.id)
      end

    rescue => ex
      LoggedException.add(__FILE__,__method__,ex)
    end #begin

    end #crawled
  end #import
end #products
