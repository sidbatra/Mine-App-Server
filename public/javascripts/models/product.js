// Product model represents a product that a
// user owns
//
Denwen.Models.Product = Backbone.Model.extend({

  // Route on the app server
  //
  urlRoot: '/products',

  // Constructor logic
  //
  initialize: function(){
    this.associate('store',Denwen.Models.Store);
  },

  // Path to the product with the originating source
  //
  path: function(src) {
    return this.urlRoot + '/' + this.get('id') + '/' + 
            this.get('handle') + '?src=' + src;
  },

  // Unique key to identify the unique combination of the
  // model name and the id
  //
  uniqueKey: function() {
    return 'product_' + this.get('id');
  }


});


