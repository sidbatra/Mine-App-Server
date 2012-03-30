// View for creating a new product
//
Denwen.Views.Products.New = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self          = this;
    this.source       = this.options.source;
    this.input        = new Denwen.Partials.Products.Input({
                                              el    : $('body'),
                                              mode  : 'new'});

    this.setAnalytics();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {

    //Denwen.Track.productNewView(
    //  this.source,
    //  this.suggestion.get('id'),
    //  this.suggestion.get('title'));

    if(Denwen.H.isOnboarding) 
      Denwen.Track.productNewViewOnboarding();

    Denwen.Track.checkForEmailClickedEvent(this.source);
  }

});
