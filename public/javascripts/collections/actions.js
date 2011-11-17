// Collection of Action models
//
Denwen.Collections.Actions = Backbone.Collection.extend({

  // Route on the app server
  //
  url: '/actions',

  // Base model
  //
  model: Denwen.Models.Action,
  
  // Constructor logic
  //
  initialize: function() {
  }

});

