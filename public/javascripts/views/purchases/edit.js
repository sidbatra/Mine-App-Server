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

    // -----
    this.updateUI();

    // -----
    this.displayFlashMessage();

    // -----
    this.setAnalytics();
  },

  // Update the UI based on the current purchase
  //
  updateUI: function() {
    this.input.displayPurchaseImage(this.purchase.get('giant_url'));

    this.input.isStoreUnknownChanged();

    if(this.purchase.get('endorsement'))
      this.input.endorsementInitiated();
  },

  // Public. Display a success or failure message if an update
  // has been initiated.
  //
  displayFlashMessage: function() {
    if(Denwen.Flash.get('updated') == true)
      Denwen.Drawer.success("Your changes have been saved.");
    else if(Denwen.Flash.get('updated') == false)
      Denwen.Drawer.error("Sorry, there was an error saving your changes.");
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    Denwen.Track.action("Purchase Edit View",{"Source" : this.source});
  }

});

