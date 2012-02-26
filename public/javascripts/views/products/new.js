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
    this.category     = new Denwen.Models.Category(this.options.categoryJSON);
    this.input        = new Denwen.Partials.Products.Input({
                                              el    : $('body'),
                                              mode  : 'new'});

    this.setAnalytics();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {

    analytics.productNewView(
        this.category.get('id'),
        this.category.get('name'),
        this.source);

    if(helpers.isOnboarding) 
      analytics.productNewViewOnboarding();

    analytics.checkForEmailClickedEvent(this.source);
  }

});
