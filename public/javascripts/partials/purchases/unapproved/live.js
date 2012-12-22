Denwen.Partials.Purchases.Unapproved.Live = Backbone.View.extend({

  initialize: function() {
    this.offset = 0;
    this.perPage = 10;
    this.oldestPurchaseID = 0;

    this.finished = false;

    this.purchasesRetryInterval = 5 * 1000;
    this.userRetryInterval = 7 * 1000;

    this.spinnerEl = this.options.spinnerEl;

    this.purchases = new Denwen.Collections.Purchases();
    this.purchases.bind('add',this.purchaseAdded,this);

    var self = this;
    setTimeout(function(){self.fetch();},10000);
    setTimeout(function(){self.fetchUser();},15000);
  },

  fetchUser: function() {
    var self = this;

    this.user = new Denwen.Models.User({
                      id: Denwen.H.currentUser.get('obfuscated_id')});
    this.user.fetch({
      success: function(){self.userLoaded();},
      error: function(){self.userLoadingFailed();}});
  },

  fetch: function() {
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
    this.finished = true;
    $(this.spinnerEl).hide();

    this.trigger(
      Denwen.Partials.Purchases.Unapproved.Live.Callback.PurchasesFinished)
  },

  retry: function() {
    if(this.finished)
      return;

    var self = this;
    this.offset = this.purchases.length;
    setTimeout(function(){self.fetch();},this.purchasesRetryInterval);
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
    if(!this.purchases.isEmpty() &&
        this.purchases.last().get('id') != this.oldestPurchaseID) {

      this.oldestPurchaseID = this.purchases.last().get('id');

      if(!this.offset) {
        this.trigger(
          Denwen.Partials.Purchases.Unapproved.Live.Callback.PurchasesStarted)
      }
    }

    this.retry();

    $('#' + this.el.attr('id') + ' a[href]').click(function(e){e.preventDefault();});
  },

  purchasesLoadingFailed: function() {
    this.retry();
  },



  // -
  // Callbacks from fetching user.
  // -

  userLoaded: function() {
    if(this.user.get('is_mining_purchases')) {
      var self = this;
      setTimeout(function(){self.fetchUser();},this.userRetryInterval);
    }
    else {
      this.purchasesFinished();
    }
  },

  userLoadingFailed: function() {
    this.fetchUser();
  }

});

Denwen.Partials.Purchases.Unapproved.Live.Callback = {
  PurchasesStarted: "purchasesStarted",
  PurchasesFinished: "purchasesFinished"
};

