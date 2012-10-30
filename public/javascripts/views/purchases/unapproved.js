Denwen.Views.Purchases.Unapproved = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.source = this.options.source;
    this.mode = this.options.mode;

    this.feedEl  = '#feed';
    this.feedSpinnerEl  = '#feed-spinner';
    this.progressMessageEl = '#progress_message';
    this.doneLoadingMessage = "Here's what we found in your email."

    this.liveMode = this.mode == "live";

    if(this.liveMode) {
      this.livePurchases = new Denwen.Partials.Purchases.Unapproved.Live({
                                el:$(this.feedEl),
                                spinnerEl:this.feedSpinnerEl});

      this.livePurchases.bind(
        Denwen.Partials.Purchases.Unapproved.Live.Callback.PurchasesFinished,
        this.livePurchasesFinished,
        this)

      this.livePurchases.bind(
        Denwen.Partials.Purchases.Unapproved.Live.Callback.PurchasesStarted,
        this.livePurchasesStarted,
        this)

      $(this.progressMessageEl).html("Finding your latest purchases...");
    }
    else {
      this.stalePurchases = new Denwen.Partials.Purchases.Unapproved.Stale({
                                  el:$(this.feedEl),
                                  spinnerEl:this.feedSpinnerEl});

      $(this.progressMessageEl).html(this.doneLoadingMessage);
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
      Denwen.Track.action("Welcome History View");
  },

  livePurchasesStarted: function() {
    console.log("STARTED");
  },

  livePurchasesFinished: function() {
    $(this.progressMessageEl).html(this.doneLoadingMessage);
  },

  // Listener for the NM callback when the cross button of a purchase
  // is clicked.
  //
  purchaseCrossClicked: function(purchase) {
    if(!this.liveMode)
      this.stalePurchases.emptySpaceTest();
  }

});
