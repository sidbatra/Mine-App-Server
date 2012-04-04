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
    this.perPage = 10;
    this.loading = false;
    this.disabled = false;

    this.feed = new Denwen.Collections.Feed();
    this.feed.bind('add',this.feedItemAdded,this);
    this.fetch();

    this.windowListener = new Denwen.WindowListener();

    this.windowListener.bind(
      Denwen.WindowListener.Callback.DocumentScrolled,
      this.documentScrolled,
      this);

    this.windowListener.bind(
      Denwen.WindowListener.Callback.ResizeEnded,
      this.resizeEnded,
      this);
  },

  // Load and display the next set of feed items.
  //
  fetch: function() {
    if(this.loading || this.disabled)
      return;

    this.loading = true;

    var self = this;
    var data = {per_page:this.perPage};

    if(!this.feed.isEmpty())
      data['before'] = this.feed.last().creationTimestamp;

    this.feed.fetch({
      add: true,
      data: data,
      success: function(){self.feedLoaded();},
      error: function(){self.feedLoadingFailed();}});
  },


  // -
  // Callbacks from fetching and populating the feed.
  // -

  // Fired when a new feed item is added to the feed collection.
  // Use this callback to render every added item.
  //
  feedItemAdded: function(product) {
    var productDisplay = new Denwen.Partials.Products.Display({
                              el: this.el,
                              model: product});
  },

  // Feed items successfully loaded. Fire events to subscribers 
  // and display items.
  //
  feedLoaded: function() {
    this.loading = false;
  },

  // Feed items loading failed. Fire events to subscribers.
  //
  feedLoadingFailed: function() {
    this.loading = false;
  },


  // -
  // Callbacks from WindowListener
  // -

  // Document has reached end of scroll area. Load more products.
  //
  documentScrolled: function() {
    this.fetch();
  },

  // Browser window resizing has just finished. Test if
  // more products are required to fill the page.
  //
  resizeEnded: function() {
    if(this.windowListener.isWindowEmpty())  {
      this.fetch();
    }
  }

});
