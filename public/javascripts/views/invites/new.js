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

    this.friendsContainerEl = '#friends_container';
    this.finishContainerEl  = '#finish_container';

    this.friendsView = new Denwen.Partials.Invites.New.Friends(
                            {el:$('#friends_container'),friends: this.friends});

    this.finishView  = new Denwen.Partials.Invites.New.Finish(
                            {el:$('#finish_container')});

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

  // Hide all subviews
  //
  hideSubViews: function() {
    $(this.friendsContainerEl).hide();
    $(this.finishContainerEl).hide();
  },

  // Use Backbone router for reacting to changes in URL
  // fragments
  //
  routing: function() {
    var self = this;

    var router = Backbone.Router.extend({

      // Listen to routes
      //
      routes: {
        "friends" : "friends",
        "friends-:name-:fbID/finish" : "finish",
        ":fragment" : "unknown"
      },

      // Display friends 
      //
      friends: function() {
        self.hideSubViews();
        self.friendsView.display();
        $(self.friendsContainerEl).show();
        self.friendsView.displayed();
      },

      // DIsplay final invite view
      //
      finish: function(name,fbID) {
        self.hideSubViews();
        self.finishView.display(
          name.replace('+',' '),
          fbID);
        $(self.finishContainerEl).show();
      },

      // Load starting tab
      //
      unknown: function(fragment) {
        this.friends();
      }
    });

    new router();
    Backbone.history.start();
  },

  // Fire tracking events
  //
  setAnalytics: function() {

    if(Denwen.H.isOnboarding)
      Denwen.Track.inviteViewOnboarding();
    else
      Denwen.Track.inviteView(this.source);

    Denwen.Track.checkForEmailClickedEvent(this.source);
  }

});
