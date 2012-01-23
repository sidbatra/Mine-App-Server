// View js for the Stores/Show route
//
Denwen.Views.Stores.Show = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.store    = new Denwen.Models.Store(this.options.storeJSON);
    this.source   = this.options.source;

    // -----
    this.products = new Denwen.Partials.Products.Products({
                          el        : $('#centerstage'),
                          owner_id  : this.store.get('id'),
                          filter    : 'store',
                          type      : 'store',
                          fragment  : 'products'});

    // -----
    this.topProducts   = new Denwen.Partials.Products.TopProducts({
                                el        : $('#top_products'),
                                owner_id  : this.store.get('id')});

    // -----
    new Denwen.Partials.Facebook.Base();

    // -----
    new Denwen.Partials.Users.TopShoppers({
                          el    : $('#top_shoppers'),
                          store : this.store});

    // -----
    this.routing();

    // -----
    this.setAnalytics();
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
        "products/:category"  : "doubleFilter",
        ":misc"               : "defaultFilter"
      },

      // Filter store products by category
      //
      doubleFilter: function(category) {
        self.products.fetch(category);
        analytics.storeProductsView(category,self.store.get('id'));
      },

      // Load all products for unknown fragments
      //
      defaultFilter: function(misc) {
        self.products.fetch();
      }
    });

    new router();
    Backbone.history.start();
  },

  // Fire various tracking events 
  //
  setAnalytics: function() {

    analytics.userLandsOn(this.store.uniqueKey());

    analytics.storeProfileView(
      this.source,
      this.store.get('id'));

    if(this.source.slice(0,6) == 'email_')
      analytics.emailClicked(this.source.slice(6,this.source.length));
  }

});
