// View js for the Stores/Show route
//
Denwen.Views.Stores.Show = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.store    = new Denwen.Models.Store(this.options.storeJSON);
    this.source   = this.options.source;

    // -----
    //this.products   = new Denwen.Partials.Products.Products({
    //                            el        : $('#products'),
    //                            owner_id  : this.store.get('id'),
    //                            filter    : 'store',
    //                            jst       : 'products/store_products',
    //                            active    : true});
    // -----
    this.shelves = new Denwen.Partials.Users.Shelves({
                                el        : $('#shelves'),
                                owner_id  : this.store.get('id')});

    // -----
    this.topProducts   = new Denwen.Partials.Products.Products({
                                el        : $('#top_products'),
                                owner_id  : this.store.get('id'),
                                filter    : 'top',
                                jst       : 'products/top_products',
                                active    : false});
    this.topProducts.fetch();

    new Denwen.Partials.Facebook.Base();

    // -----
    new Denwen.Partials.Users.TopShoppers({
                          el    : $('#top_shoppers'),
                          store : this.store});

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

    if(this.source.slice(0,6) == 'email_')
      analytics.emailClicked(this.source.slice(6,this.source.length));
  },

});
