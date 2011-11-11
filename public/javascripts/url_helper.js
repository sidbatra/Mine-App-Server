// Url helper helps create routes for use in javascript templates
//
Denwen.UrlHelper = Backbone.Model.extend({

  //Constructor logic
  //
  initialize: function() {
    this.usersRoot = '/users';
  },

  // Generate a route to the given user profile
  // with the given src
  //
  userPath: function(id,src) {
    return this.usersRoot + '/' + id + '?src=' + src; 
  }

});
