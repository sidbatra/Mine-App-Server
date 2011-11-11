// Collection of User models holding the user's iFollowers 
//
Denwen.Users = Backbone.Collection.extend({

  // Model name
  //
  model: Denwen.User,

  // Route on the app server 
  //
  url: '/users',

  // Constructor logic
  //
  initialize: function() {
  }

});
