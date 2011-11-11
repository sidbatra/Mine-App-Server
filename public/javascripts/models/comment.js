// The Comment model represents user comments
// on products
//
Denwen.Models.Comment = Backbone.Model.extend({

  // Route on the app server
  //
  urlRoot: '/comments',

  // Constructor logic
  //
  initialize: function() {
    var user = new Denwen.User(this.get('user'));
    this.unset('user',{silent:true});
    this.set({user:user},{silent:true});

    user.path('product');
  },

  // Validation logic
  //
  validate: function(attrs) {
    if(attrs.data.length < 1 || attrs.data == this.get('defaultData')) 
      return "No comment entered";
  }

});


