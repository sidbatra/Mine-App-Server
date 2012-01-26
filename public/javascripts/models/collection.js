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
    this.associate('user',Denwen.Models.User);
    this.associate('products',Denwen.Collections.Products);
  },

  // Path to the collection with the originating source
  //
  path: function(src) {
    return '/' + this.get('user').get('handle') + '/c/' + 
            this.get('id') + '?src=' + src;
  }

});


