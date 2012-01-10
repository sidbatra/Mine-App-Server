// Search model stores queries made by the user
// while searching for products
//
Denwen.Models.Search = Backbone.Model.extend({

  // Route on the app server
  //
  urlRoot: '/searches',

  // Constructor logic
  //
  initialize: function() {
  },

  // Validation logic
  //
  validate: function(attrs) {
    if(attrs.query.length < 1)
      return "No query entered";
  }

});
