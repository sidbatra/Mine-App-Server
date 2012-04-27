// View for editing an existing purchase
//
Denwen.Views.Purchases.Edit = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self         = this;
    this.purchase     = new Denwen.Models.Purchase(this.options.purchaseJSON);
    this.input       = new Denwen.Partials.Purchases.Input({
                            el:$('body'),
                            mode:Denwen.PurchaseFormType.Edit});
    this.source      = this.options.source;

    this.updateUI();

    this.setAnalytics();
  },

  // Update the UI based on the current purchase
  //
  updateUI: function() {
    this.input.displayPurchaseImage(this.purchase.get('giant_url'));

    this.input.isStoreUnknownChanged();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {

    Denwen.Track.purchaseEditView(
        this.purchase.get('id'),
        this.source);
  }

});

