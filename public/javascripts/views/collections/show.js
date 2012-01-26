// View js for Collections/Show route
//
Denwen.Views.Collections.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.collection = new Denwen.Models.Collection(this.options.collectionJSON);
    this.source     = this.options.source;

    new Denwen.Partials.Commentables.Comments({
          commentable_id    : this.collection.get('id'),
          commentable_type  : 'collection',
          el                : $('#comments_container')});

    new Denwen.Partials.Actionables.Actions({
          actionable_id       : this.collection.get('id'),
          actionable_type     : 'collection',
          actionable_user_id  : this.collection.get('user_id'),
          el                  : $('#feedback')});

    this.setAnalytics();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    analytics.collectionView(this.source);
  }

});
