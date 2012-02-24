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

  // Base of collection paths
  //
  pathBase: function() {
    return '/' + this.get('user').get('handle') + '/s/' + this.get('handle');
  },

  // Path to the collection with the originating source
  //
  path: function(src) {
    return this.pathBase() + '?src=' + src;
  },

  // Path to editing the collection with the originating source
  //
  editPath: function(src) {
    return this.pathBase() + '/edit?src=' + src;
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


