// View for fetching and displaying the content of a user's feed.
//
Denwen.Partials.Purchases.Unapproved.Stale = Backbone.View.extend({

  initialize: function() {
    this.oldestItemTimestamp = 0;
    this.perPage = 100;
    this.loading = false;
    this.disabled = false;
    this.spinnerEl = this.options.spinnerEl;


    this.purchases = new Denwen.Collections.Purchases();
    this.purchases.bind('add',this.purchaseAdded,this);
    this.fetch();


    this.infiniteScroller = new Denwen.InfiniteScroller();

    this.infiniteScroller.bind(
      Denwen.InfiniteScroller.Callback.EndReached,
      this.endReached,
      this);

    this.infiniteScroller.bind(
      Denwen.InfiniteScroller.Callback.EmptySpaceFound,
      this.emptySpaceFound,
      this);
  },

  // Load and display the next set of feed items.
  //
  fetch: function() {
    if(this.loading || this.disabled)
      return;

    this.loading = true;

    var data = {per_page: this.perPage, aspect:'unapproved'};

    if(this.oldestItemTimestamp)
      data['before'] = this.oldestItemTimestamp;

    var self = this;
    this.purchases.fetch({
      add: true,
      data: data,
      success: function(){self.purchasesLoaded();},
      error: function(){self.purchasesLoadingFailed();}});
  },

  purchasesFinished: function() {
    this.disabled = true;
    $(this.spinnerEl).hide();
    this.trigger(Denwen.Partials.Purchases.Unapproved.Stale.Callback.PurchasesFinished);
  },


  // -
  // Callbacks from fetching and populating the feed.
  // -

  // Fired when a new feed item is added to the purchases collection.
  // Use this callback to render every added item.
  //
  // purchase - Denwen.Models.Purchase. The purchase added to the collection.
  //
  purchaseAdded: function(purchase) {
    var purchaseDisplay = new Denwen.Partials.Purchases.Display({
                              el: this.el,
                              model: purchase,
                              interaction: false,
                              crossButton: true});
  },

  purchasesLoaded: function() {
    this.loading = false;

    if(this.purchases.isEmpty()) {
      this.purchasesFinished();
    }
    else {
      var newOldestItemTimestamp = this.purchases.last().creationTimestamp;

      if(this.oldestItemTimestamp == newOldestItemTimestamp) {
        this.purchasesFinished();
      }
      else if(!this.oldestItemTimestamp) {
        this.trigger(
          Denwen.Partials.Purchases.Unapproved.Stale.Callback.PurchasesStarted);
      }

      this.oldestItemTimestamp = newOldestItemTimestamp;

      this.fetch();
    }

    $('#' + this.el.attr('id') + ' a[href]').click(function(e){e.preventDefault();});

    $('[data-toggle="modal"]').removeAttr('data-toggle');
    //this.emptySpaceTest();
  },

  purchasesLoadingFailed: function() {
    this.loading = false;
  },

  emptySpaceTest: function() {
    this.infiniteScroller.emptySpaceTest();
  },


  // -
  // Callbacks from InfiniteScroller
  // -

  // Document has reached end of scroll area. Load more purchases.
  //
  endReached: function() {
    //this.fetch();
  },

  // Document hasn't fully filled out the window.
  //
  emptySpaceFound: function() {
    //this.fetch();
  }

});

Denwen.Partials.Purchases.Unapproved.Stale.Callback = {
  PurchasesStarted: "purchasesStarted",
  PurchasesFinished: "purchasesFinished"
};
