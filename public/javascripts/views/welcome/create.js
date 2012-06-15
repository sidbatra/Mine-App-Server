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
    this.nextURL = this.options.nextURL;

    this.step1Heading = '#step_1';
    this.step2Heading = '#step_2';
    this.hintEl = '#hint';
    this.examplesEl = '#examples';

    this.input = new Denwen.Partials.Purchases.Input({
                        el  : $('body'),
                        scrollOnSelection : false,
                        resetOnCreation : false,
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
    $(this.step1Heading).hide();
    $(this.step2Heading).show();
    $(this.hintEl).hide();
    $(this.examplesEl).hide();
  },

  // Display the freshly created purchase in the feed.
  //
  purchaseCreated: function(purchase) {
    window.location.href = this.nextURL;
  },

  // Display a creation error.
  //
  purchaseCreationFailed: function() {
  }

});

