// View js for the Stores/Show route
//
Denwen.Views.Stores.Show = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.store        = new Denwen.Models.Store(this.options.storeJSON);
    this.source       = this.options.source;
    this.productsTab  = '#products_tab';
    this.currentTab   = undefined;
    this.loadTabClass = 'load';

    // -----
    this.products = new Denwen.Partials.Products.Products({
                          el          : $('#centerstage'),
                          owner_id    : this.store.get('id'),
                          owner_name  : this.store.get('name'),
                          filter      : 'store',
                          type        : 'store',
                          fragment    : 'products'});

    this.products.bind(
      Denwen.Callback.ProductsLoaded,
      this.productsLoaded,
      this);

    // -----
    this.topProducts   = new Denwen.Partials.Products.TopProducts({
                                el        : $('#top_products'),
                                owner_id  : this.store.get('id')});

    // -----
    new Denwen.Partials.Facebook.Base();

    // -----
    //new Denwen.Partials.Users.TopShoppers({
    //                      el    : $('#top_shoppers'),
    //                      store : this.store});

    // -----
    new Denwen.Partials.Stores.Related({
          el      : $('#related_stores_box'),
          store   : this.store});

    // -----
    this.routing();

    // -----
    this.setAnalytics();
  },

  // Switch on the given tab element
  //
  switchTabOn: function(tab) {
    this.currentTab = tab;
    $(tab).addClass(this.loadTabClass);
  },

  // Remove loading state from the current tab
  //
  switchCurrentTabLoadOff: function() {
    $(this.currentTab).removeClass(this.loadTabClass);
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
        ":type" : "filter"
      },

      // Load all products for unknown fragments
      //
      filter: function(type) {
        self.products.fetch();
        self.switchTabOn(self.productsTab);
        analytics.storeProductsView(self.store.get('id'));
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

    analytics.checkForEmailClickedEvent(this.source);
  },

  // Callback when store products are loaded
  //
  productsLoaded: function() {
    this.switchCurrentTabLoadOff();
  }

});
