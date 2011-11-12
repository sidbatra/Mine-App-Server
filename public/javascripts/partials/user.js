// Render a single user 
//
Denwen.Partials.User = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.render();
  },

  // Render a user 
  //
  render: function() {
    $(this.el).prepend(Denwen.JST['users/user']({user:this.model}));
  }

});
