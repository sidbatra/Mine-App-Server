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
    //if(attrs.byline.length < 1)
    //  return "Byline can't be empty";
  }

});


