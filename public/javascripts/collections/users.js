// Collection of User models holding the user's iFollowers 
//
Denwen.Collections.Users = Backbone.Collection.extend({

  // Model name
  //
  model: Denwen.Models.User,

  // Route on the app server 
  //
  url: '/users',

  // Constructor logic
  //
  initialize: function() {
  }

});
