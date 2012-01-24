// View js for Collections/Show route
//
Denwen.Views.Collections.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.collection = new Denwen.Models.Collection(this.options.collectionJSON);
    this.source     = this.options.source;

    new Denwen.Partials.Collections.Comments({
          collection_id : this.collection.get('id'),
          el            : $('#comments_container')});

    new Denwen.Partials.Collections.Actions({
          collection_id       : this.collection.get('id'),
          collection_user_id  : this.collection.get('user_id'),
          el                  : $('#feedback')});

    this.setAnalytics();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {

  }

});
