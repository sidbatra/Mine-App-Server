module DW

  module PurchaseExtraction
    

    class PurchaseExtractor
      
      def initialize
        @user = nil
        @stores = nil
        @existing_purchases = nil
        @email_connection = nil
        @start_date = DateTime.new 2012,1,1,0,0,0
      end

      def populate_email_parseable_stores
        store = Store.find_by_name "Amazon"
        store[:email] = "ship-confirm@amazon.com"
        @stores = [store]
      end

      def populate_existing_purchases
        @existing_purchases = Set.new Purchase.select(:orig_image_url).
                                        for_users([@user]).
                                        map(&:orig_image_url)
      end

      def open_email_connection
        if @user.google_authorized?
          @email_connection = EmailConnection.new(
                                @user.go_email,
                                EmailProvider::Gmail, {
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
            :uid => purchase[:uid].to_s,
            :text => purchase[:text]}
        })
      end

      def mine_emails_for_user(user)
        @user = user

        populate_email_parseable_stores
        populate_existing_purchases

        open_email_connection

        @stores.each do |store|
          mine_emails_from_store store
        end 
      end

    end #purchase extractor

  end #purchase extraction

end #dw
