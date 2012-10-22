module DW

  module PurchaseExtraction
    

    class PurchaseExtractor
      
      # Extract purchases from given user's connected
      # email account.
      #
      def self.extract_from_emails_for_user(user)
        email_connection = nil
        stores = ["ship-confirm@amazon.com"]

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
          email_connection.search(store,DateTime.new(2012,1,1,0,0,0)) do |emails|
            emails.each{|email| puts email.subject}
          end
        end #stores
      end #extra from emails

    end #purchase extractor

  end #purchase extraction

end #dw
