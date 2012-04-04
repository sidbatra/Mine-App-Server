// Collection of Like models 
//
Denwen.Collections.Likes = Backbone.Collection.extend({

  // Model Name
  //
  model: Denwen.Models.Like,

  // Route on the app server 
  //
  url: '/likes',

  // Constructor logic
  //
  initialize: function() {
  }

});
