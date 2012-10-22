module DW

  module EmailConnectionInterface
    
    class EmailConnection

      # Create a new email connection based on
      # domain of given email. Provider is of type
      # EmailProvider. Options hash must
      # include required authentication params.
      #
      def initialize(email,provider,options={})
        @connection = nil

        case provider
        when EmailProvider::Gmail
          @connection = GmailConnection.new email,options
        end
      end

      # Extend the method_missing method to enable email connection
      # to act as a shell for email connection classes.
      #
      def method_missing(method,*args,&block)

        if @connection.respond_to? method
          @connection.send method,*args,&block
        else
          super
        end
      end
    end #email connection


    class GmailConnection
      
      def initialize(email,options={})
        @gmail = Gmail.connect! :xoauth, email,
                      :token           => options[:token],
                      :secret          => options[:secret],
                      :consumer_key    => options[:consumer_key],
                      :consumer_secret => options[:consumer_secret]
        @mailbox = Gmail::Mailbox.new @gmail,"[Gmail]/All Mail"
      end
      
      # Return Mail objects from all emails matching the given criterea.
      #
      def search(from,after)
        emails = @mailbox.find(:from => from,:after => after)

        emails.reverse.in_groups_of(3,false).each do |group| 
          yield @gmail.conn.uid_fetch(group.map(&:uid),"RFC822").
                        map{|d| d.attr["RFC822"]}.
                        map{|message| Mail.new(message)} if block_given?
        end
      end

    end #gmail connection

  end #email connection interface

end #dw
