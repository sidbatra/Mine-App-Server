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

    if(this.query != sane_query) {
      this.query = sane_query;
      this.trigger(Denwen.Callback.ProductResultsQueryEdit,sane_query);
    }
    else if(!data['products'].length || this.isURLQuery()) {
      this.finished = true;
      this.trigger(Denwen.Callback.ProductResultsFinished);
    }

    this.title = data['title'];

    if(this.isURLQuery() && data['products']) {
      var self = this;

      _.each(data['products'],function(product){
        product['large_url'] = product['medium_url'];
        product['source_url'] = self.query;
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
      add : true,
      data : {page: this.page,q: this.query},
      success: function() {self.productsLoaded();},
      error: function(r,s,e){}});
  },

  // Fired when products have been successfully fetched
  //
  productsLoaded: function() {
    this.searching = false;

    this.trigger(Denwen.Callback.ProductResultsLoaded);

    if(this.isEmpty()) {
      this.finished = true;
      this.trigger(Denwen.Callback.ProductResultsEmpty);
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
