// View for sending one or multiple invites
//
Denwen.Views.Invites.New = Backbone.View.extend({
  
  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.source   = this.options.source;
    this.friends  = new Denwen.Collections.Users(this.options.friends);

    new Denwen.Partials.Invites.Friends(
                          {el:$('#friends_container'),friends: this.friends});

    // -----
    this.loadFacebookPlugs();
  },

  // Load facebook code via partials
  //
  loadFacebookPlugs: function() {
    new Denwen.Partials.Facebook.Base();
  },

  // Fire tracking events
  //
  setAnalytics: function() {
    Denwen.Track.inviteView(this.source);
  }

});
