// View for editing collections
//
Denwen.Views.Collections.Edit = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.source      = this.options.source;
    this.currentUser = new Denwen.Models.User(this.options.currentUserJSON);

    new Denwen.Partials.Collections.Input({
          el            : $('#edit_collection'),
          currentUserID : this.currentUser.get('id')});

    this.setAnalytics();
  },

  // Fire tracking events
  //
  setAnalytics: function() {
    analytics.collectionEditView(this.source);
  }

});
