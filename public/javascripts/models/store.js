// Store model represents a store on the website 
//
Denwen.Models.Store = Backbone.Model.extend({

  // Route on the app server 
  //
  urlRoot: '/stores',

  // Constructor logic
  //
  initialize: function(){
  },

  // Generate a path to the store profile
  // with the given source
  //
  path: function(src) {
    return '/s/' + this.get('handle') + '?src=' + src;
  },

  // Unique key to identify the unique combination of the
  // model name and the id
  //
  uniqueKey: function() {
    return 'store_' + this.get('id');
  }
});
