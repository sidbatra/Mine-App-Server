// View for creating new collections
//
Denwen.Views.Collections.New = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.source      = this.options.source;
    this.currentUser = new Denwen.Models.User(this.options.currentUserJSON);

    new Denwen.Partials.Collections.Input({
          el            : $('#new_collection'),
          productIDs    : [],
          currentUserID : this.currentUser.get('id')});

    this.setAnalytics();
  },

  // Fire tracking events
  //
  setAnalytics: function() {
    analytics.collectionNewView(this.source);
  }

});
