// User model represents a user of the site
//
Denwen.Models.User = Backbone.Model.extend({
  
  // Route on the app server
  //
  urlRoot: '/users',

  // Constructor logic
  //
  initialize: function() {
    this.associate('setting',Denwen.Models.Setting);
  },

  // Validation logic
  //
  validate: function(attrs) {
  },

  fullName: function() {
    return this.get('first_name') + ' ' + this.get('last_name');
  },

  // Generate a path to the user profile
  // with the given source
  //
  path: function(src) {
    return '/' + this.get('handle') + '?src=' + src;
  },

  // Unique key to identify the unique combination of the
  // model name and the id
  //
  uniqueKey: function() {
    return 'user_' + this.get('id');
  },

  pronoun: function() {
    return this.get('gender') == "male" ? "his" : "her";
  }

});


