Denwen.Partials.Purchases.Unapproved.Live = Backbone.View.extend({

  initialize: function() {
    this.offset = 0;
    this.perPage = 10;
    this.oldestPurchaseID = 0;

    this.emptyTries = 0;
    this.maxEmptyTries = 3;

    this.defaultRetryInterval = 2;
    this.retryInterval = this.defaultRetryInterval;
    this.retryDelta = 3;

    this.loading = false;
    this.spinnerEl = this.options.spinnerEl;

    this.purchases = new Denwen.Collections.Purchases();
    this.purchases.bind('add',this.purchaseAdded,this);

    var self = this;
    setTimeout(function(){self.fetch();},10000);
  },

  fetch: function() {
    if(this.loading)
      return;

    this.loading = true;

    var self = this;
    var data = {per_page: this.perPage,
                offset: this.offset,
                aspect:'unapproved',
                by_created_at: true};

    this.purchases.fetch({
      add: true,
      data: data,
      success: function(){self.purchasesLoaded();},
      error: function(){self.purchasesLoadingFailed();}});
  },

  purchasesFinished: function() {
    $(this.spinnerEl).hide();

    this.trigger(
      Denwen.Partials.Purchases.Unapproved.Live.Callback.PurchasesFinished)
  },

  retry: function(success) {
    if(!success) {
      if(this.emptyTries++ >= this.maxEmptyTries) {
        this.purchasesFinished();
        return;
      }
      else {
        this.retryInterval += this.retryDelta;
      }
    }
    else {
      this.retryInterval = this.defaultRetryInterval;
      this.emptyTries = 0;
      this.offset = this.purchases.length;
    }

    var self = this;
    setTimeout(function(){self.fetch();},this.retryInterval * 1000);
  },


  // -
  // Callbacks from fetching purchases.
  // -

  purchaseAdded: function(purchase) {
    var purchaseDisplay = new Denwen.Partials.Purchases.Display({
                              el: this.el,
                              model: purchase,
                              interaction: false,
                              crossButton: true});
  },

  purchasesLoaded: function() {
    this.loading = false;

    if(this.purchases.isEmpty() || 
        this.purchases.last().get('id') == this.oldestPurchaseID) {

        this.retry(false);
    }
    else {
      this.oldestPurchaseID = this.purchases.last().get('id');

      if(!this.offset) {
        this.trigger(
          Denwen.Partials.Purchases.Unapproved.Live.Callback.PurchasesStarted)
      }

      this.retry(true);

    }
  },

  purchasesLoadingFailed: function() {
    this.loading = false;
    this.retry(false);
  }

});

Denwen.Partials.Purchases.Unapproved.Live.Callback = {
  PurchasesStarted: "purchasesStarted",
  PurchasesFinished: "purchasesFinished"
};

