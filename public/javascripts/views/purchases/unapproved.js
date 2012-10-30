Denwen.Views.Purchases.Unapproved = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.source = this.options.source;
    this.mode = this.options.mode;
    this.liveMode = this.mode == "live";
    this.rejectedPurchaseIDs = [];

    this.feedEl  = '#feed';
    this.feedSpinnerEl  = '#feed-spinner';
    this.progressMessageEl = '#progress_message';
    this.submitEl = '#submit_button';
    this.submitEnabled = false;
    this.doneLoadingMessage = "Here's what we found in your email."


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
      this.submitEnabled = true;

      this.stalePurchases = new Denwen.Partials.Purchases.Unapproved.Stale({
                                  el:$(this.feedEl),
                                  spinnerEl:this.feedSpinnerEl});

      $(this.progressMessageEl).html(this.doneLoadingMessage);
    }

    Denwen.NM.bind(
      Denwen.NotificationManager.Callback.PurchaseCrossClicked,
      this.purchaseCrossClicked,
      this);

    $(this.submitEl).click(function(){self.submitClicked();return false;});

    this.setAnalytics();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    Denwen.Track.action("Unapproved Purchases View",{"Source" : this.source});

    if(Denwen.H.isOnboarding)
      Denwen.Track.action("Welcome History View");
  },

  submitClicked: function() {
    if(!this.submitEnabled)
      return false;
    
    var self = this;

    selectedPurchaseIDs = (this.liveMode ? 
                                this.livePurchases.purchases : 
                                this.stalePurchases.purchases).pluck('id');

    _.each(this.rejectedPurchaseIDs,function(id){
      selectedPurchaseIDs.splice(selectedPurchaseIDs.indexOf(id),1);
    });

    console.log(selectedPurchaseIDs);
    console.log(this.rejectedPurchaseIDs);

    this.submitEnabled = false;
  },


  // --
  // Callbacks from live purchases
  // --

  livePurchasesStarted: function() {
  },

  livePurchasesFinished: function() {
    $(this.progressMessageEl).html(this.doneLoadingMessage);
  },

  // Listener for the NM callback when the cross button of a purchase
  // is clicked.
  //
  purchaseCrossClicked: function(purchase) {
    this.rejectedPurchaseIDs.push(purchase.get('id'));

    if(!this.liveMode)
      this.stalePurchases.emptySpaceTest();
  }

});
