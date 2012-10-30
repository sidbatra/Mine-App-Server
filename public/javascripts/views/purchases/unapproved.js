Denwen.Views.Purchases.Unapproved = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.source = this.options.source;

    this.feedEl  = '#feed';
    this.feedSpinnerEl  = '#feed-spinner';

    this.liveMode = this.source == "live";

    if(this.liveMode) {
      this.livePurchases = new Denwen.Partials.Purchases.Unapproved.Live({
                                el:$(this.feedEl),
                                spinnerEl:this.feedSpinnerEl});
    }
    else {
      this.stalePurchases = new Denwen.Partials.Purchases.Unapproved.Stale({
                                  el:$(this.feedEl),
                                  spinnerEl:this.feedSpinnerEl});
    }

    Denwen.NM.bind(
      Denwen.NotificationManager.Callback.PurchaseCrossClicked,
      this.purchaseCrossClicked,
      this);

    this.setAnalytics();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    Denwen.Track.action("Unapproved Purchases View",{"Source" : this.source});

    if(Denwen.H.isOnboarding)
      Denwen.Track.action("Welcome Purchase Email View");
  },

  // Listener for the NM callback when the cross button of a purchase
  // is clicked.
  //
  purchaseCrossClicked: function(purchase) {
    if(!this.liveMode)
      this.stalePurchases.emptySpaceTest();
  }

});
