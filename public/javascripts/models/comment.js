// The Comment model represents user comments
// on products
//
Denwen.Comment = Backbone.Model.extend({

  // Route on the app server
  //
  urlRoot: '/comments',

  // Constructor logic
  //
  initialize: function() {
  },

  // Validation logic
  //
  validate: function(attrs) {
    if(attrs.data.length < 1 || attrs.data == this.get('defaultData')) 
      return "No comment entered";
  }

});


