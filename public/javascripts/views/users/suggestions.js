Denwen.Views.Users.Suggestions = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.user    = Denwen.H.currentUser;
    this.source  = this.options.source;
    this.userSuggestionsEl  = '#user_suggestions_box';

    // -----
    new Denwen.Partials.Users.Box({
      el: $('#user_box'),
      user: this.user
    });

    // -----
    new Denwen.Partials.Users.Suggestions({
      el:$(this.userSuggestionsEl),
      perPage: 10
      });

    // -----
    this.setAnalytics();
  },

  // Fire various tracking events 
  //
  setAnalytics: function() {
    Denwen.Track.action("User Suggestions View",{"Source" : this.source});
    Denwen.Track.isEmailClicked(this.source);
  }
  
});
