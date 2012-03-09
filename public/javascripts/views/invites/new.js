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
    this.styles   = new Backbone.Collection(this.options.styles);

    this.stylesContainerEl  = '#styles_container';
    this.friendsContainerEl = '#friends_container';
    this.finishContainerEl  = '#finish_container';

    this.stylesView  = new Denwen.Partials.Invites.New.Styles(
                            {el:$('#styles_container')});

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
    $(this.stylesContainerEl).hide();
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
        "styles-:styleID/friends" : "friends",
        "styles-:styleID/friends-:name-:fbID/finish" : "finish",
        ":fragment" : "unknown"
      },

      // Display styles tab
      //
      styles: function() {
        self.hideSubViews();
        self.stylesView.display();
        $(self.stylesContainerEl).show();
      },

      // Display friends after a style is chosen
      //
      friends: function(styleID) {
        self.hideSubViews();
        self.friendsView.display(styleID);
        $(self.friendsContainerEl).show();
        self.friendsView.displayed();
      },

      // DIsplay final invite view
      //
      finish: function(styleID,name,fbID) {
        self.hideSubViews();
        self.finishView.display(
          styleID,
          self.styles.get(styleID).get('title'),
          name.replace('+',' '),
          fbID);
        $(self.finishContainerEl).show();
      },

      // Load starting tab
      //
      unknown: function(fragment) {
        this.styles();
      }
    });

    new router();
    Backbone.history.start();
  },

  // Fire tracking events
  //
  setAnalytics: function() {

    if(helpers.isOnboarding)
      analytics.inviteViewOnboarding();
    else
      analytics.inviteView(this.source);

    analytics.checkForEmailClickedEvent(this.source);
  }

});
