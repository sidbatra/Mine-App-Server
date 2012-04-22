// View for displaying a user's feed.
//
Denwen.Views.Feed.Show = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.source       = this.options.source;
    this.currentUser  = new Denwen.Models.User(this.options.currentUserJSON);

    this.feedEl   = '#feed';

    this.content  = new Denwen.Partials.Feed.Content({el:$(this.feedEl)});
    this.input    = new Denwen.Partials.Purchases.Input({
                          el  : $('body'),
                          mode: Denwen.PurchaseFormType.New});

    this.input.bind(
      Denwen.Partials.Purchases.Input.Callback.PurchaseCreated,
      this.purchaseCreated,
      this);

    this.input.bind(
      Denwen.Partials.Purchases.Input.Callback.PurchaseCreationFailed,
      this.purchaseCreationFailed,
      this);
    
    this.loadFacebookPlugs();

    this.setAnalytics();
  },

  // Load facebook code via partials
  //
  loadFacebookPlugs: function() {
    new Denwen.Partials.Facebook.Base();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    Denwen.Track.checkForEmailClickedEvent(this.source);
  },

  // --
  // Callbacks from Products.Input
  // --

  // Display the freshly created product in the feed.
  //
  purchaseCreated: function(product) {
    this.content.insert(product);
  },

  // Display a creation error.
  //
  purchaseCreationFailed: function() {
    //console.log("Error creating product");
  }

});
