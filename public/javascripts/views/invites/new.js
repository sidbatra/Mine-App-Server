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
    this.source = this.options.source;
    this.friends = new Denwen.Partials.Invites.Friends({
                        el:$('#friends_container'),
                        friends: new Denwen.Collections.Users(this.options.friends)});

    // -----
    this.routing();

    // -----
    this.loadFacebookPlugs();

    // -----
    this.setAnalytics();
  },

  // Load facebook code via partials
  //
  loadFacebookPlugs: function() {
    new Denwen.Partials.Facebook.Base();
  },

  // Use Backbone router for reacting to changes in
  // URL hash fragments. Used to launch external searches.
  //
  routing: function() {
    var self = this;

    var router = Backbone.Router.extend({

      // Listen to routes
      //
      routes: {
        "search/:query" : "search"
      },

      // Launch search. 
      //
      search: function(query) {
        self.friends.search(query.replace('-',' '));
      }
    });

    new router();
    Backbone.history.start();
  },

  // Fire tracking events
  //
  setAnalytics: function() {
    Denwen.Track.action("Invite View",{"Source" : this.source});
  }

});
