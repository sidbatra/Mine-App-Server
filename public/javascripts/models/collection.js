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
  },

  // String for the total count of likes
  //
  likes_count_string: function() {
    return this.get('actions_count') ? this.get('actions_count') : '';
  },

  // String for the total count of comments
  //
  comments_count_string: function() {
    return this.get('comments_count') ? this.get('comments_count') : '';
  }

});


