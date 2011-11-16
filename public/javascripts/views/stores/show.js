// View js for the Stores/Show route
//
Denwen.Views.Stores.Show = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.store    = new Denwen.Models.Store(this.options.storeJSON);
    this.source   = this.options.source;

    // -----
    this.products   = new Denwen.Partials.Products.Products({
                                el        : $('#products'),
                                owner_id  : this.store.get('id'),
                                filter    : 'store',
                                jst       : 'products/store_products'});

    // -----
    this.routing();

    new Denwen.Partials.Facebook.Base();

    // -----
    this.setAnalytics();
  },

  // Fire various tracking events 
  //
  setAnalytics: function() {

    analytics.userLandsOn(this.store.uniqueKey());

    analytics.storeProfileView(
      this.source,
      this.store.get('id'));
  },
  
  // Use Backbone router for reacting to changes in URL
  // fragments
  //
  routing: function() {
    var self = this;

    var router = Backbone.Router.extend({

      // Listen to routes
      //
      routes: {
        ":category" : "filter"
      },

      // Called when a filter route is fired
      //
      filter: function(category) {
        self.products.fetch(category);

        if(category != undefined && category.length) {
          analytics.storeProfileFiltered(
                      category,
                      self.store.get('id'));
        }
      }
    });

    new router();
    Backbone.history.start();
  }

});
