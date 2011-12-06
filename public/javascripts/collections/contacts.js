// Collection of Contact models 
//
Denwen.Collections.Contacts = Backbone.Collection.extend({

  // Model name
  //
  model: Denwen.Models.Contact,

  // Route on the app server 
  //
  url: '/contacts',

  // Constructor logic
  //
  initialize: function() {
  }

});
