// The Collection model represents user collectionss
// of products
//
Denwen.Models.Collection = Backbone.Model.extend({

  // Route on the app server
  //
  urlRoot: '/collections',

  // Constructor logic
  //
  initialize: function() {
    this.associate('products',Denwen.Collections.Products);
  }

});


