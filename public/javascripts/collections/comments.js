// Collection of User models
//
Denwen.Comments = Backbone.Collection.extend({

  // Route on the app server
  //
  url: '/comments',

  // Base model
  //
  model: Denwen.Comment,
  
  // Constructor logic
  //
  initialize: function() {
  }

});
