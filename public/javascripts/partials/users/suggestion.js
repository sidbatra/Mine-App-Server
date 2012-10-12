Denwen.Partials.Users.Suggestion = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
   this.render();   

   new Denwen.Partials.Followings.Following({
        el: $('#follow_box_' + this.model.get('id')),
        userID: this.model.get('id')});
  },

  // Override render method for displaying view
  //
  render: function() {
    this.el.append(Denwen.JST['users/suggestion']({user:this.model}));
  }
});
