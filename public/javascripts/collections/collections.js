// Collection of Collection models
//
Denwen.Collections.Collections = Backbone.Collection.extend({

  // Route on the app server
  //
  url: '/collections',

  // Base model
  //
  model: Denwen.Models.Collection,
  
  // Constructor logic
  //
  initialize: function() {
  }

});
