// User model represents a user of the site
//
Denwen.User = Backbone.Model.extend({
  
  // Route on the app server
  //
  urlRoot: '/users',

  // Constructor logic
  //
  initialize: function() {
  },

  // Validation logic
  //
  validate: function(attrs) {
  },

  // Generate a path to the user profile
  // with the given source
  //
  path: function(src) {
    return this.urlRoot + '/' + this.id + '?src=' + src;
  }

});


