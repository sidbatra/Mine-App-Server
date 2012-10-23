module DW

  module PurchaseEmailParsing
    
    class PurchaseEmailParser
      def initialize(store)
        @parser = Object.const_get("#{store.name.capitalize}EmailParser").send :new 
      end

      # Extend the method_missing method to enable purchase email parser
      # to act as a shell for email parser classes.
      #
      def method_missing(method,*args,&block)

        if @parser.respond_to? method
          @parser.send method,*args,&block
        else
          super
        end
      end
    end 



    class AmazonEmailParser
      def parse(emails)
        purchases = []

        emails.each do |email|
          product_ids = email.html_part.to_s.
                          scan(/www.amazon.com\/dp\/([^r]+)\/ref/).
                          flatten.
                          uniq
          product_ids.each do |product_id|
            purchase = {}
            purchase[:product_id] = product_id
            purchase[:bought_at] = email.date

            purchases << purchase
          end
        end

        purchases.each do |purchase|
          puts purchase[:product_id] + "," + purchase[:bought_at].to_s
        end
      end
    end

  end #purchase email parsing

end #dw
