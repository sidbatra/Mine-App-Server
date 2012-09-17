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
    this.facebookBoxEl = "#facebook_box";
    this.emailBoxEl = "#email_box";
    this.facebookTabEl = "#facebook_tab";
    this.emailTabEl = "#email_tab";
    this.friendsBoxEl = "#friends_container";

    new Denwen.Partials.Invites.Email({el:this.el});


    if(Denwen.H.currentUser.get('setting').get('fb_auth')) {
      this.loadFacebookContacts();
    }
    else {
      var self = this;

      this.fbConnectBoxEl = "#facebook_connect_box";
      this.fbConnectEl = "#facebook_connect";
      this.fbLoadClass = 'load';

      this.fbAuth = new Denwen.Partials.Auth.Facebook();

      this.fbAuth.bind(
        Denwen.Partials.Auth.Facebook.Callback.AuthAccepted,
        this.fbAuthAccepted,
        this);

      this.fbAuth.bind(
        Denwen.Partials.Auth.Facebook.Callback.AuthRejected,
        this.fbAuthRejected,
        this);


      $(this.fbConnectEl).click(function(){self.fbConnectClicked()});
    }

    // -----
    this.routing();

    // -----
    this.loadFacebookPlugs();

    // -----
    this.setAnalytics();

   $("#search_box").placeholder();
  },

  fbConnectClicked: function() {
    this.fbAuth.showAuthDialog();
  },

  loadFacebookContacts: function() {
    this.friends = new Denwen.Partials.Invites.Friends({
                        el:$('#friends_container'),
                        invite_handle: this.options.invite_handle, 
                        friends: new Denwen.Collections.Users(this.options.friends)});
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
        "search/:query" : "search",
        "facebook" : "facebookTab",
        "email" : "emailTab"
      },

      // Launch search. 
      //
      search: function(query) {
        self.friends.search(query.replace('-',' '));
      },

      facebookTab: function() {
        $(self.emailTabEl).removeClass('on');
        $(self.emailTabEl).addClass('off');
        $(self.emailBoxEl).hide();
        $(self.facebookTabEl).removeClass('off');
        $(self.facebookTabEl).addClass('on');
        $(self.facebookBoxEl).show();
      },

      emailTab: function() {
        $(self.facebookTabEl).removeClass('on');
        $(self.facebookTabEl).addClass('off');
        $(self.facebookBoxEl).hide();
        $(self.emailTabEl).removeClass('off');
        $(self.emailTabEl).addClass('on');
        $(self.emailBoxEl).show();
      }
    });

    new router();
    Backbone.history.start();
  },

  // Fire tracking events
  //
  setAnalytics: function() {
    Denwen.Track.action("Invite View",{"Source" : this.source});
  },

  //
  // Callbacks from fb auth interface.
  //

  // Fired when fb auth is accepted 
  //
  fbAuthAccepted: function() {
    $(this.fbConnectEl).removeClass(this.fbLoadClass);
    $(this.fbConnectBoxEl).hide();
    $(this.friendsBoxEl).show();

    this.loadFacebookContacts();
  },

  // Fired when fb auth is rejected
  //
  fbAuthRejected: function() {
    $(this.fbConnectEl).removeClass(this.fbLoadClass);
    Denwen.Drawer.error("Facebook connect is required to find your friends.");
  }

});
