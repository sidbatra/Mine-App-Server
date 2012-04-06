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

    this.feed = new Denwen.Collections.Feed();
    this.feed.bind('add',this.feedItemAdded,this);
    this.fetch();

    this.windowListener = new Denwen.WindowListener();

    this.likes          = new Denwen.Partials.Likes.Likes();
    this.comments       = new Denwen.Partials.Comments.Comments();

    this.productIds     = [];

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

    if(this.oldestItemTimestamp)
      data['before'] = this.oldestItemTimestamp;

    this.feed.fetch({
      add: true,
      data: data,
      success: function(){self.feedLoaded();},
      error: function(){self.feedLoadingFailed();}});
  },

  // Add a freshly created product into the collection and ui.
  //
  // product - Denwen.Models.Product. The product to be added 
  //            to the collection.
  //
  insert: function(product) {
    product.set({fresh:true});
    this.feed.add(product,{at:0});
  },


  // -
  // Callbacks from fetching and populating the feed.
  // -

  // Fired when a new feed item is added to the feed collection.
  // Use this callback to render every added item.
  //
  // product - Denwen.Models.Product . The product added to the collection.
  //
  feedItemAdded: function(product) {
    var productDisplay = new Denwen.Partials.Products.Display({
                              el: this.el,
                              model: product});

    this.productIds.push(product.get('id'));
  },

  // Feed items successfully loaded. Fire events to subscribers 
  // and display items.
  //
  feedLoaded: function() {
    this.loading = false;

    if(this.feed.isEmpty()) {
      this.disabled = true;
    }
    else {
      var newOldestItemTimestamp = this.feed.last().creationTimestamp;

      if(this.oldestItemTimestamp == newOldestItemTimestamp)
        this.disabled = true;

      this.oldestItemTimestamp = newOldestItemTimestamp;
    }

    if(this.productIds.length) {
      this.likes.fetch(this.productIds.join(","));
      this.comments.fetch(this.productIds.join(","));

      this.productIds = []; 
    }

    this.resizeEnded();
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
