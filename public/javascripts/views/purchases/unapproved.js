Denwen.Views.Purchases.Unapproved = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.source = this.options.source;
    this.mode = this.options.mode;
    this.successURL = this.options.successURL;
    this.successZeroURL = this.options.successZeroURL;
    this.liveMode = this.mode == "live";
    this.rejectedPurchaseIDs = [];

    this.feedEl  = '#feed';
    this.feedSpinnerEl  = '#feed_spinner';
    this.progressBarEl = '#progress_bar';
    this.progressStoreEl = '#progress_store';
    this.progressMessageEl = '#progress_message';
    this.centralMessageEl = '#central_message';
    this.submitEl = '';
    this.submitEls = $('a.purchases-submit');
    this.submitEnabled = false;


    if(this.liveMode) {
      this.livePurchases = new Denwen.Partials.Purchases.Unapproved.Live({
                                el:$(this.feedEl),
                                spinnerEl:this.feedSpinnerEl});

      this.livePurchases.bind(
        Denwen.Partials.Purchases.Unapproved.Live.Callback.PurchasesFinished,
        this.livePurchasesFinished,
        this);

      this.livePurchases.bind(
        Denwen.Partials.Purchases.Unapproved.Live.Callback.PurchasesProgress,
        this.livePurchasesProgress,
        this);

      this.livePurchases.bind(
        Denwen.Partials.Purchases.Unapproved.Live.Callback.PurchasesStarted,
        this.livePurchasesStarted,
        this);

      $(this.progressMessageEl).addClass('working');
    }
    else {
      this.stalePurchases = new Denwen.Partials.Purchases.Unapproved.Stale({
                                  el:$(this.feedEl),
                                  spinnerEl:this.feedSpinnerEl});

      this.stalePurchases.bind(
        Denwen.Partials.Purchases.Unapproved.Stale.Callback.PurchasesFinished,
        this.stalePurchasesFinished,
        this);

      this.stalePurchases.bind(
        Denwen.Partials.Purchases.Unapproved.Stale.Callback.PurchasesStarted,
        this.stalePurchasesStarted,
        this);
    }

    Denwen.NM.bind(
      Denwen.NotificationManager.Callback.PurchaseCrossClicked,
      this.purchaseCrossClicked,
      this);

    //$(this.submitEl).click(function(){self.submitClicked();return false;});
    $(this.submitEls).click(function(){self.submitEl = '#' + this.id;self.submitClicked();return false;});

    this.setAnalytics();
  },

  //
  //
  updateProgressUI: function(progress,store) {
    var percent = 100 - progress * 100 + '%';
    $(this.progressBarEl).css('right',percent);

    if(store) {
      $(this.progressStoreEl).html(Denwen.JST['purchases/importer/store']({
        storeImageURL: store.get('medium_url')
        }));
    }
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    Denwen.Track.action("Unapproved Purchases View",{"Source" : this.source});

    if(Denwen.H.isOnboarding)
      Denwen.Track.action("Welcome History View");
  },

  enableSubmitButton: function() {
    //$(this.submitEl).removeClass('disabled');
    $(this.submitEl).removeClass('load');
    this.submitEnabled = true;
  },

  disableSubmitButton: function(withSpinner) {
    if(withSpinner)
      $(this.submitEl).addClass('load');
    //else
    //  $(this.submitEl).addClass('disabled');

    this.submitEnabled = false;
  },

  submitClicked: function() {
    if(!this.submitEnabled)
      return false;

    Denwen.Track.action("Import Purchases Clicked");
    
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

    this.selectedPurchasesCount = selectedPurchaseIDs.length;
    this.disableSubmitButton(true);
  },

  // --
  // Callbacks from purchases approval
  // --
  purchasesApproved: function() {
    window.location.href = this.selectedPurchasesCount ? 
                            this.successURL :
                            this.successZeroURL;
  },

  purchasesApprovalFailed: function() {
    this.enableSubmitButton();
  },

  // --
  // Callbacks from live purchases
  // --

  livePurchasesStarted: function() {
    $(this.centralMessageEl).hide();
  },

  livePurchasesProgress: function(progress,store) {
    this.updateProgressUI(progress,store);
  },

  livePurchasesFinished: function() {
    this.updateProgressUI(1,null);

    $(this.progressMessageEl).addClass('complete');

    if(this.livePurchases.purchases.isEmpty()) {
      $(this.centralMessageEl).addClass('nothing');
      $(this.progressMessageEl).hide();
    }
    else {
      this.enableSubmitButton();
    }
  },

  // --
  // Callbacks from stale purchases
  // --

  stalePurchasesStarted: function() {
    $(this.centralMessageEl).hide();
  },

  stalePurchasesFinished: function() {
    this.updateProgressUI(1,null);

    $(this.progressMessageEl).addClass('update');

    if(this.stalePurchases.purchases.isEmpty()) {
      $(this.centralMessageEl).addClass('nothing');
      $(this.progressMessageEl).hide();
    }
    else {
      this.enableSubmitButton();
    }
  },

  // Listener for the NM callback when the cross button of a purchase
  // is clicked.
  //
  purchaseCrossClicked: function(purchase) {
    this.rejectedPurchaseIDs.push(purchase.get('id'));
  }

});
