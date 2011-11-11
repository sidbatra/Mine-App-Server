// Collection of User models
//
Denwen.Collections.Comments = Backbone.Collection.extend({

  // Route on the app server
  //
  url: '/comments',

  // Base model
  //
  model: Denwen.Models.Comment,
  
  // Constructor logic
  //
  initialize: function() {
  }

});
