Denwen.Collections.Products = Backbone.Collection.extend({

  // Model name
  //
  model: Denwen.Models.Product,

  // Route on the app server
  //
  url: '/products',

  // Constructor logic
  //
  initialize: function() {
    this.query      = '';
    this.title      = '';
    this.page       = 0;
    this.searching  = false;
    this.finished   = false;
    this.queryType  = Denwen.ProductQueryType.Text;
    this.unmatchedQuery = false;
  },

  // Initiate a new search
  //
  search: function(query) {
    this.reset();

    this.query      = query;
    this.title      = '';
    this.page       = 0;
    this.searching  = true;
    this.finished   = false;
    this.queryType  = this.query.match(/http/) ? 
                        Denwen.ProductQueryType.URL : 
                        Denwen.ProductQueryType.Text;
    this.unmatchedQuery = false;

    this.fetchProducts();
  },

  // Load more results for the current search
  //
  searchMore: function() {
    if(this.searching || this.finished)
      return;

    this.page++;
    this.searching = true;

    this.fetchProducts();
  },

  // Custom parsing to strip out extra fields in the json.
  // Fired automatically after the json is fetched and before
  // its passed to any success methods.
  //
  // data - Associative Array. Response json in raw form.
  //
  // returns - Array. Products part of the received data.
  //
  parse: function(data) {
    var sane_query = data['sane_query'];
    var query = data['query'];

    if(this.query != query) {
      this.unmatchedQuery = true;
      return [];
    }


    if(this.query != sane_query) {
      this.query = sane_query;
      this.trigger(Denwen.Collections.Products.Callback.QueryFixed,sane_query);
    }

    if(!data['products'].length || this.isURLQuery()) {
      this.finished = true;
      this.trigger(Denwen.Collections.Products.Callback.Finished);
    }

    this.title = data['title'];

    if(this.isURLQuery() && data['products']) {
      var self = this;

      _.each(data['products'],function(product){
        //product['large_url'] = product['medium_url'];
        //product['source_url'] = self.query;
        product['title'] = self.title;
      });
    }
    else if(data['products']) {
      var self = this;

      _.each(data['products'],function(product){
        if(!product['title'].length)
          product['title'] = self.query;
      });
    }

    return data['products'];
  },

  // Fetch products from the server and append to the current
  // set of results.
  //
  fetchProducts: function() {
    var self = this;

    this.fetch({
      add: true,
      data: {page: this.page,q: this.query},
      success: function() {self.productsLoaded();},
      error: function(r,s,e){}});
  },

  // Fired when products have been successfully fetched
  //
  productsLoaded: function() {
    this.searching = false;

    this.trigger(Denwen.Collections.Products.Callback.Loaded);

    if(this.isEmpty()) {
      this.finished = true;

      if(!this.unmatchedQuery)
        this.trigger(Denwen.Collections.Products.Callback.Empty);
    }
  },

  // Test is the current search query is URL based
  //
  // returns. Boolean. true if the query type is url based.
  //
  isURLQuery: function() {
    return this.queryType == Denwen.ProductQueryType.URL;
  },

  // Canonical title for any product result in this search group.
  //
  // returns - String. Title.
  //
  currentSearchTitle: function() {
    return this.queryType  == Denwen.ProductQueryType.Text ? 
            this.query : 
            this.title;
  }

});

// Define callbacks.
//
Denwen.Collections.Products.Callback = {
  Loaded : 'loaded',
  Empty : 'empty',
  Fininished : 'finished',
  QueryFixed : 'queryFixed'
}
