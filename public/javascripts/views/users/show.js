// View js for the Users/Show route
//
Denwen.Views.Users.Show = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },
  
  // Constructor logic
  //
  initialize: function() {
    this.user = new Denwen.Models.User(this.options.userJSON);
    this.oldestItemTimestamp = 0;
    this.loading = false;
    this.disabled = false;
    this.feedEl = '#feed';
    this.spinnerEl = '#feed-spinner';
    this.source = this.options.source;

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


    // -----
    new Denwen.Partials.Users.Box({
      el: $('#user_box'),
      user: this.user
    });

    // -----
    $("a[rel='tooltip']").tooltip();

    // -----
    //$(".source-url").click(function(){
    //                        Denwen.Track.purchaseURLVisit('profile')});

    // -----
    this.loadFacebookPlugs();

    // -----
    this.displayFlashMessage();

    // -----
    this.setAnalytics();
  },

  fetch: function() {
    if(this.loading || this.disabled)
      return;

    this.loading = true;

    var self = this;
    var data = {per_page:10,aspect:'user',user_id: this.user.get('id')};

    if(this.oldestItemTimestamp)
      data['before'] = this.oldestItemTimestamp;

    this.purchases.fetch({
      add: true,
      data: data,
      success: function(){self.purchasesLoaded();},
      error: function(){self.purchasesLoadingFailed();}});
  },

  // Load facebook code via partials
  //
  loadFacebookPlugs: function() {
    new Denwen.Partials.Facebook.Base();
  },

  // Public. Display a success or failure message if a flash related
  // event has been initiated.
  //
  displayFlashMessage: function() {
    if(Denwen.Flash.get('destroyed') == true) {
      Denwen.Drawer.success("Your purchase has been deleted.");
      Denwen.Track.action("Purchase Deleted");
    }
    else if(Denwen.Flash.get('destroyed') == false)
      Denwen.Drawer.error("Sorry, there was an error deleting your purchase.");
  },

  // Fire various tracking events 
  //
  setAnalytics: function() {
    Denwen.Track.action("User View",{"Source" : this.source});
    Denwen.Track.isEmailClicked(this.source);
    Denwen.Track.origin("user");
  },


  // -
  // Callbacks from fetching and populating the feed.
  // -

  purchaseAdded: function(purchase) {
    var purchaseDisplay = new Denwen.Partials.Purchases.Display({
                              el: $(this.feedEl),
                              model: purchase});
  },

  purchasesLoaded: function() {
    this.loading = false;

    if(this.purchases.isEmpty()) {
      this.disabled = true;
      $(this.spinnerEl).hide();
    }
    else {
      var newOldestItemTimestamp = this.purchases.last().creationTimestamp;

      if(this.oldestItemTimestamp == newOldestItemTimestamp) {
        this.disabled = true;
        $(this.spinnerEl).hide();
      }

      this.oldestItemTimestamp = newOldestItemTimestamp;
    }

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
