module DW

  module PurchaseExtraction
    

    class PurchaseExtractor
      
      def initialize
        @user = nil
        @stores = nil
        @existing_purchases = nil
        @email_connection = nil
        @provider = nil
        @start_date = DateTime.new 2012,1,1,0,0,0
      end

      def populate_email_parseable_stores
        @stores = []

        Store.with_email_parse_datum.parseable.each do |store|
          store.email_parse_datum.emails.split(",").each do |email|
            store_clone = store.clone
            store_clone[:email] = email

            @stores << store_clone
          end
        end
      end

      def populate_existing_purchases
        @existing_purchases = Set.new Purchase.select(:orig_image_url).
                                        for_users([@user]).
                                        map(&:orig_image_url)
      end

      def open_email_connection
        if @user.google_authorized?
          @provider = EmailProvider::Gmail
          @email_connection = EmailConnection.new(
                                @user.go_email,
                                @provider, {
                                  :token => @user.go_token,
                                  :secret => @user.go_secret,
                                  :consumer_key => CONFIG[:google_client_id],
                                  :consumer_secret => CONFIG[:google_client_secret]})
        end
      end

      def mine_emails_from_store(store)
        parser = PurchaseEmailParser.new store

        @email_connection.search(store[:email],@start_date) do |emails|
          purchases = parser.parse emails

          purchases.each do |purchase| 
            next if @existing_purchases.include? purchase[:orig_image_url]

            augment_purchase_hash purchase,store
            Purchase.add purchase,@user.id 

            @existing_purchases.add purchase[:orig_image_url]
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
        @user = user

        populate_email_parseable_stores
        populate_existing_purchases

        open_email_connection


        @stores.in_groups_of(3,false) do |group|
          threads = []

          group.each do |store|
            threads << Thread.new{mine_emails_from_store store}
          end

          threads.each {|thread| thread.join}
        end 
      end

    end #purchase extractor

  end #purchase extraction

end #dw
