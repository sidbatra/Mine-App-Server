// Collection of Comment models 
//
Denwen.Collections.Comments = Backbone.Collection.extend({

  // Model Name
  //
  model: Denwen.Models.Comment,

  // Route on the app server 
  //
  url: '/comments',

  // Constructor logic
  //
  initialize: function() {
  }

});
