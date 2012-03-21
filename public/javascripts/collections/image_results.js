// Collection of ImageResult models holding image search results
//
Denwen.Collections.ImageResults = Backbone.Collection.extend({

  // Model name
  //
  model: Denwen.Models.ImageResult,

  // Route on the app server
  //
  url: '/search',

  // Constructor logic
  //
  initialize: function() {
    this.query      = '';
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
    this.page       = 0;
    this.searching  = true;
    this.finished   = false;

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
    else if(!data['products'].length) {
      this.finished = true;
      this.trigger(Denwen.Callback.ProductResultsFinished);
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
  }

});
