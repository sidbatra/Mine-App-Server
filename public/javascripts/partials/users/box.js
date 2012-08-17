// View for handling a user box with a byline and follow button.
//
Denwen.Partials.Users.Box = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.user = this.options.user;

    if(Denwen.H.isCurrentUser(this.user.get('id'))) {
      new Denwen.Partials.Users.Byline({
            el: $('#user_byline_box'),
            model: this.user});
    }
    else {
      new Denwen.Partials.Followings.Following({
            el:$('#follow_box'),
            userID: this.user.get('id')});
    }
  }
});

