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

  // Unique key to identify the unique combination of the
  // model name and the id
  //
  uniqueKey: function() {
    return 'collection_' + this.get('id');
  },

  // Path to the collection with the originating source
  //
  path: function(src) {
    return '/' + this.get('user').get('handle') + '/c/' + 
            this.get('id') + '?src=' + src;
  },

  // Likes count string after a like has been initiated
  //
  pushed_likes_count_string: function() {
    var count = this.get('actions_count') + helpers.isLoggedIn();
    return count ? count : '';
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


