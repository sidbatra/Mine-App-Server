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
      this.enableSubmitButton();

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

  enableSubmitButton: function() {
    $(this.submitEl).removeClass('load');
    this.submitEnabled = true;
  },

  disableSubmitButton: function(withSpinner) {
    if(withSpinner)
      $(this.submitEl).addClass('load');

    this.submitEnabled = false;
  },

  submitClicked: function() {
    if(!this.submitEnabled)
      return false;
    
    var self = this;

    var selectedPurchaseIDs = (this.liveMode ? 
                                this.livePurchases.purchases : 
                                this.stalePurchases.purchases).pluck('id');

    _.each(this.rejectedPurchaseIDs,function(id){
      selectedPurchaseIDs.splice(selectedPurchaseIDs.indexOf(id),1);
    });

    $.ajax({
      type: 'put',
      url: "/purchases/update_multiple.json",
      data: {aspect: 'approval', selected_ids: selectedPurchaseIDs.join(), rejected_ids: this.rejectedPurchaseIDs.join()},
      success: function(data) {self.purchasesApproved();},
      error: function() {self.purchasesApprovalFailed();}});

    this.disableSubmitButton(true);
  },

  // --
  // Callbacks from purchases approval
  // --
  purchasesApproved: function() {
    window.location.href = "/" + Denwen.H.currentUser.get('handle') + "?src=history";
  },

  purchasesApprovalFailed: function() {
    this.enableSubmitButton();
  },

  // --
  // Callbacks from live purchases
  // --

  livePurchasesStarted: function() {
    this.enableSubmitButton();
  },

  livePurchasesFinished: function() {
    this.enableSubmitButton();
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
