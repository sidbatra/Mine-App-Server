module MarketBot
  module Android

    # Search query pages are extremely similar to leaderboard pages.
    # Amazingly, this inheritence hack works!
    class SearchQuery < MarketBot::Android::Leaderboard
      def initialze(query, options={})
        super(query, nil, options)
      end

      def market_urls(options={})
        results = []

        min_page = 1 
        max_page = 1 

        (min_page..max_page).each do |page|
          start_val = (page - 1) * 2

          url = "https://play.google.com/store/search?"
          url << "q=#{URI.escape(identifier)}&"
          url << "c=apps&start=#{start_val}&"
          url << "num=2&hl=en"

          results << url
        end

        results
      end
    end

  end
end
