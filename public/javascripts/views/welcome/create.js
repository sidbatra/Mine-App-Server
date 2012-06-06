// 
//
Denwen.Views.Welcome.Create = Backbone.View.extend({
  
  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.hintEl = '#hint';
    this.examplesEl = '#examples';

    this.input = new Denwen.Partials.Purchases.Input({
                        el  : $('body'),
                        scrollOnSelection : false,
                        mode: Denwen.PurchaseFormType.New});

    this.input.bind(
      Denwen.Partials.Purchases.Input.Callback.ProductSelected,
      this.productSelected,
      this);

    this.input.bind(
      Denwen.Partials.Purchases.Input.Callback.PurchaseCreated,
      this.purchaseCreated,
      this);

    this.input.bind(
      Denwen.Partials.Purchases.Input.Callback.PurchaseCreationFailed,
      this.purchaseCreationFailed,
      this);


    this.setAnalytics();
  },

  // Fire tracking events
  //
  setAnalytics: function() {
    Denwen.Track.action("Welcome Create View");
  },

  // --
  // Callbacks from Purchases.Input
  // --

  // Cleanup ui after a product has been selected.
  //
  productSelected: function(product) {
    $(this.hintEl).hide();
    $(this.examplesEl).hide();
  },

  // Display the freshly created purchase in the feed.
  //
  purchaseCreated: function(purchase) {
    Denwen.Track.action("Welcome Purchase Created");
  },

  // Display a creation error.
  //
  purchaseCreationFailed: function() {
  }

});

