// Collection of models within a feed.
//
Denwen.Collections.Feed = Backbone.Collection.extend({

  // Route on the app server
  //
  url: '/feed',

  // Base model
  //
  model: Denwen.Models.Product,

  // Constructor logic
  //
  initialize: function () {
  }

});
