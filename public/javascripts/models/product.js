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

    if(this.get('created_at'))
      this.creationTimestamp = this.get('created_at').toDate().getTime() * 0.001;
  },

  // Base path to the product with any additional args
  //
  basePath: function() {
    return '/' + this.get('user').get('handle') + '/p/' + 
      this.get('handle');
  },

  // Path to the product with the originating source
  //
  path: function(src) {
    return this.basePath() + '?src=' + src;
  },

  // Path to the edit view of the product with an originating source
  //
  editPath: function(src) {
    return this.basePath() + '/edit?src=' + src;
  },

  // Unique key to identify the unique combination of the
  // model name and the id
  //
  uniqueKey: function() {
    return 'product_' + this.get('id');
  },
  
  // Returns whether or not the product is shared on facebook
  //
  isShared: function() {
    return this.get('fb_object_id') && 
           (this.get('fb_object_id') != Denwen.FBSharing.Underway); 
  }

});


