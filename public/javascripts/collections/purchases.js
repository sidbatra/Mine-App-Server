// Collection of Purchase models
//
Denwen.Collections.Purchases = Backbone.Collection.extend({

  // Route on the app server
  //
  url: '/purchases',

  // Base model
  //
  model: Denwen.Models.Purchase,

  // Constructor logic
  //
  initialize: function () {
  }

});
