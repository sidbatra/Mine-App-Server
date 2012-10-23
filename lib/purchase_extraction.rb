module DW

  module PurchaseExtraction
    

    class PurchaseExtractor
      
      # Extract purchases from given user's connected
      # email account.
      #
      def self.extract_from_emails_for_user(user)
        email_connection = nil

        #For testing only
        store = Store.find_by_name "Amazon"
        store[:email] = "ship-confirm@amazon.com"
        stores = [store]

        if user.google_authorized?
          email_connection = EmailConnection.new(
                              user.go_email,
                              EmailProvider::Gmail, {
                                :token => user.go_token,
                                :secret => user.go_secret,
                                :consumer_key => CONFIG[:google_client_id],
                                :consumer_secret => CONFIG[:google_client_secret]})
        end


        stores.each do |store|
          parser = PurchaseEmailParser.new store

          email_connection.search(store[:email],DateTime.new(2012,1,1,0,0,0)) do |emails|
            purchases = parser.parse emails
            p purchases
          end
        end #stores

      end #extract from emails


    end #purchase extractor

  end #purchase extraction

end #dw
