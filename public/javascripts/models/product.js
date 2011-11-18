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
    this.associate('user',Denwen.Models.User);
  },

  // Path to the product with the originating source
  //
  path: function(src) {
    return '/' + this.get('user').get('handle') + '/p/' + 
            this.get('handle') + '?src=' + src;
  },

  // Unique key to identify the unique combination of the
  // model name and the id
  //
  uniqueKey: function() {
    return 'product_' + this.get('id');
  },

  // Override the toJSON implementation
  //
  toJSON: function() {
    return {product:{endorsement:this.get('endorsement')}};
  },

});


