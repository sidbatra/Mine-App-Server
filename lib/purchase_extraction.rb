module DW

  module PurchaseExtraction
    

    class PurchaseExtractor
      
      def initialize(start_date=DateTime.new(2011,10,1,0,0,0))
        @user = nil
        @stores = nil
        @existing_purchases = nil
        @email_connection = nil
        @provider = nil
        @start_date = start_date
      end

      def populate_email_parseable_stores
        @stores = []

        Store.with_email_parse_datum.parseable.each do |store|
          store.email_parse_datum.emails.split(",").each do |email|
            store_clone = store.clone
            store_clone.id = store.id
            store_clone[:email] = email

            @stores << store_clone
          end
        end
      end

      def populate_existing_purchases
        @existing_purchases = Set.new 

        Purchase.select(:id,:orig_image_url,:product_id).
                  with_product.
                  for_users([@user]).
                  each do |purchase|
                    @existing_purchases.add purchase.orig_image_url

                    if purchase.product && purchase.product.external_id.present?
                      @existing_purchases.add purchase.product.external_id 
                    end
                  end
      end

      def populate_authorized_emails
        @emails = @user.authorized_emails
      end

      def open_email_connection(email)
        status = false
        @provider = email

        case @provider
        when EmailProvider::Gmail
          status = true

          begin
            @email_connection = EmailConnection.new(
                                  @user.go_email,
                                  @provider, {
                                    :token => @user.go_token,
                                    :secret => @user.go_secret,
                                    :consumer_key => CONFIG[:google_client_id],
                                    :consumer_secret => CONFIG[:google_client_secret]})
          rescue Gmail::Client::AuthorizationError
            status = false
            @user.google_disconnect
          end

        when EmailProvider::Yahoo
          status = true

          begin
            @user.refresh_yahoo_token
            @email_connection = EmailConnection.new(
                                  @user.yh_email,
                                  @provider, {
                                    :token => @user.yh_token,
                                    :secret => @user.yh_secret})
          rescue OAuth::Problem
            status = false
            @user.yahoo_disconnect
          end

        when EmailProvider::Hotmail
          status = true

          begin
            @email_connection = EmailConnection.new(
                                  @user.hm_email,
                                  @provider, {
                                    :password => @user.hm_password,
                                    :start_date => @start_date,
                                    :email_regex => Regexp.new(@stores.map(&:email).join("|"))})
          
          rescue Net::POPError => ex
            puts ex.message
          rescue Net::POPAuthenticationError
            status = false
            @user.hotmail_disconnect
          end
        end

        status
      end
      
      def update_mining_progress(store,progress)
        if store
          metadata = {
                      :progress => "%0.3f" % progress,
                      :store => {
                        :id => store.id,
                        :name => store.name,
                        :medium_url => store.medium_url}}

          @user.email_mining_metadata = metadata.to_json
        else
          @user.email_mining_metadata = nil
        end

        @user.save!
      end

      def mine_emails_from_store(store)
        parser = PurchaseEmailParser.new store

        @email_connection.search(store[:email],@start_date) do |emails|
          purchases = parser.parse emails

          purchases.each do |purchase| 
          begin
            #puts purchase[:title]

            next if @existing_purchases.include?(purchase[:orig_image_url]) ||
                    @existing_purchases.include?(purchase[:external_id]) ||
                    !purchase[:title].present? ||
                    !purchase[:orig_image_url].present?

            augment_purchase_hash purchase,store
            Purchase.add purchase,@user.id 

            @existing_purchases.add purchase[:orig_image_url]
            @existing_purchases.add purchase[:external_id]
          rescue => ex
            LoggedException.add(__FILE__,__method__,ex)
          end
          end
        end

      rescue => ex
        LoggedException.add(__FILE__,__method__,ex)
      end

      def augment_purchase_hash(purchase,store)
        purchase.merge!({
          :source => PurchaseSource::Email,
          :is_approved => false,
          :store_id => store.id,
          :query => URI.unescape(purchase[:source_url]),
          :product => {
            :title => purchase[:title],
            :external_id => purchase[:external_id]},
          :email => {
            :message_id => purchase[:message_id],
            :text => purchase[:text],
            :provider => @provider}
        })
      end

      def mine_emails_for_user(user)
        return if user.is_mining_purchases

        @user = user
        @user.is_mining_purchases = true
        @user.save!

        start_time = Time.now


        populate_email_parseable_stores
        populate_existing_purchases
        populate_authorized_emails


        @emails.each do |email|
          next unless open_email_connection(email)

          #@stores.in_groups_of(3,false) do |group|
            #threads = []

            @stores.each_with_index do |store,index|
              update_mining_progress store,(index + 1.0)/ @stores.length
              #threads << Thread.new{mine_emails_from_store store}
              mine_emails_from_store store
            end

            #threads.each {|thread| thread.join}
          #end #stores

        end #emails

        @user.email_mined_till = start_time

      ensure
        if @user
          update_mining_progress nil,0
          @user.is_mining_purchases = false
          @user.save!
        end
      end

      def audit_for_user(user)
        @user = user

        return unless open_email_connection

        file = File.open "data.txt","a"

        @email_connection.fulltext_search("order shipped",@start_date) do |emails|

          emails.each do |email|
            file.puts "#{@user.id.to_s}\t#{email.from.to_s}\t#{email.subject}"
          end
        end

        file.close
      end

    end #purchase extractor

  end #purchase extraction

end #dw
