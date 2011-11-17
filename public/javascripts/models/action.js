// The Action model represents user actions
// on products
//
Denwen.Models.Action = Backbone.Model.extend({

  // Route on the app server
  //
  urlRoot: '/actions',

  // Constructor logic
  //
  initialize: function() {
    this.associate('user',Denwen.Models.User);
  },

  // Validation logic
  //
  validate: function(attrs) {
  }

});



