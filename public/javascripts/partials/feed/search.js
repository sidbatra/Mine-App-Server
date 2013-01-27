Denwen.Partials.Feed.Search = Backbone.View.extend({

  initialize: function() {
    this.page = 1;
    this.perPage = 10;
    this.query = "";
    this.loading = false;
    this.disabled = true;
    this.spinnerEl = '#feed-spinner';

    this.purchases = new Denwen.Collections.Purchases();
    this.purchases.bind('add',this.purchaseAdded,this);

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

  appear: function(query) {
    this.query = query;
    this.disabled = false;
    this.el.html('');
    $(this.spinnerEl).show();

    this.fetch();
  },

  disappear: function() {
    this.disabled = true;
  },

  // Load and display the next set of feed items.
  //
  fetch: function() {
    if(this.loading || this.disabled)
      return;

    this.loading = true;

    var self = this;

    this.purchases.fetch({
      add: true,
      data: {q: this.query,aspect: 'search',per_page:this.perPage,page:this.page},
      success: function(){self.purchasesLoaded();},
      error: function(){self.purchasesLoadingFailed();}});
  },


  // -
  // Callbacks from fetching and populating purchases.
  // -

  purchaseAdded: function(purchase) {
    var purchaseDisplay = new Denwen.Partials.Purchases.Display({
                              el: this.el,
                              model: purchase,
                              interaction: true});
  },

  purchasesLoaded: function() {
    this.loading = false;

    if(this.purchases.isEmpty()) {
      this.disabled = true;
      $(this.spinnerEl).hide();
    }

    this.page++;
    this.infiniteScroller.emptySpaceTest();
  },

  purchasesLoadingFailed: function() {
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

