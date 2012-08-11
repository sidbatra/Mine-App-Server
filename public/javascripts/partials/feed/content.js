// View for fetching and displaying the content of a user's feed.
//
Denwen.Partials.Feed.Content = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.oldestItemTimestamp = 0;
    this.perPage = 10;
    this.loading = false;
    this.disabled = false;
    this.spinnerEl = '#feed-spinner';
    this.aspect = this.options.aspect;

    this.feed = new Denwen.Collections.Feed();
    this.feed.bind('add',this.feedItemAdded,this);
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

    var self = this;
    var data = {per_page:this.perPage,aspect:this.aspect};

    if(this.oldestItemTimestamp)
      data['before'] = this.oldestItemTimestamp;

    this.feed.fetch({
      add: true,
      data: data,
      success: function(){self.feedLoaded();},
      error: function(){self.feedLoadingFailed();}});
  },

  // Add a freshly created purchase into the collection and ui.
  //
  // purchase - Denwen.Models.Purchase. The purchase to be added 
  //            to the collection.
  //
  insert: function(purchase) {
    purchase.set({fresh:true});
    this.feed.add(purchase,{at:0});
  },


  // -
  // Callbacks from fetching and populating the feed.
  // -

  // Fired when a new feed item is added to the feed collection.
  // Use this callback to render every added item.
  //
  // purchase - Denwen.Models.Purchase. The purchase added to the collection.
  //
  feedItemAdded: function(purchase) {
    var purchaseDisplay = new Denwen.Partials.Purchases.Display({
                              el: this.el,
                              model: purchase,
                              interaction: this.aspect == 'user'});
  },

  // Feed items successfully loaded. Fire events to subscribers 
  // and display items.
  //
  feedLoaded: function() {
    this.loading = false;

    if(this.feed.isEmpty()) {
      this.disabled = true;
      $(this.spinnerEl).hide();
    }
    else {
      var newOldestItemTimestamp = this.feed.last().creationTimestamp;

      if(this.oldestItemTimestamp == newOldestItemTimestamp) {
        this.disabled = true;
        $(this.spinnerEl).hide();
      }

      this.oldestItemTimestamp = newOldestItemTimestamp;
    }

    this.infiniteScroller.emptySpaceTest();
  },

  // Feed items loading failed. Fire events to subscribers.
  //
  feedLoadingFailed: function() {
    this.loading = false;
  },


  // -
  // Callbacks from InfiniteScroller
  // -

  // Document has reached end of scroll area. Load more purchases.
  //
  endReached: function() {
    this.fetch();
  },

  // Document hasn't fully filled out the window.
  //
  emptySpaceFound: function() {
    this.fetch();
  }

});
