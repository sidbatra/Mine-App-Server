// View js for the User/Connections route.
//
Denwen.Views.Users.Connections = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.user    = new Denwen.Models.User(this.options.userJSON);
    this.source  = this.options.source;

    // -----
    new Denwen.Partials.Users.Box({
      el: $('#user_box'),
      user: this.user
    });

    if(Denwen.H.isLoggedIn()){
      new Denwen.Partials.Followings.Followings();
    }

    // -----
    this.setAnalytics();
  },

  // Fire various tracking events 
  //
  setAnalytics: function() {
    Denwen.Track.action("User Connections View",{"Source" : this.source});
    Denwen.Track.isEmailClicked(this.source);
    Denwen.Track.origin("connections");
  }
  
});
