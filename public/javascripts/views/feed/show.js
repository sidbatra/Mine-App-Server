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
    var self      = this;
    this.source   = this.options.source;
    this.feedEl   = '#feed';
    this.input    = new Denwen.Partials.Products.Input({
                          el  : $('body'),
                          mode: Denwen.ProductFormType.New});
    
    this.comments = new Denwen.Partials.Comments.Comments();
    this.likes    = new Denwen.Partials.Likes.Likes();

    this.input.bind(
      Denwen.Partials.Products.Input.Callback.ProductCreated,
      this.productCreated,
      this);

    this.input.bind(
      Denwen.Partials.Products.Input.Callback.ProductCreationFailed,
      this.productCreationFailed,
      this);

    this.setAnalytics();
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
  productCreated: function(product) {
    $(this.feedEl).prepend(product.get('html'));
  },

  // Display a creation error.
  //
  productCreationFailed: function() {
    console.log("ERROR");
  }

});
