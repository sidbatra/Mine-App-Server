// Collect of Product models
//
Denwen.Collections.Products = Backbone.Collection.extend({

  // Route on the app server
  //
  url: '/products',

  // Base model
  //
  model: Denwen.Models.Product,

  // Constructor logic
  //
  initialize: function () {
  }

});
