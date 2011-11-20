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
    var names   = ['endorsement','price','store_name',
                    'is_gift','is_store_unknown','source_product_id'];
    var params  = {};

    for(i in names) {
      var name = names[i];

      if(this.has(name))
        params[name] = this.get(name);
    }
    
    return {product:params};
  }

});


