// Collection of Invite models 
//
Denwen.Collections.Invites = Backbone.Collection.extend({

  // Model name
  //
  model: Denwen.Models.Invite,

  // Route on the app server 
  //
  url: '/invites',

  // Constructor logic
  //
  initialize: function() {
  }

});
