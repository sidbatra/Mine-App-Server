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
    this.source  = this.options.source;
    this.styles  = new Backbone.Collection(this.options.styles);

    this.stylesContainerEl  = '#styles_container';
    this.friendsContainerEl = '#friends_container';
    this.finishContainerEl  = '#finish_container';

    this.friendsView = new Denwen.Partials.Invites.New.Friends(
                            {el:$('#friends_container')});

    // -----
    this.routing();

    // -----
    this.setAnalytics();
  },

  // Fired when the user completes an invite
  //
  //inviteCompleted: function(fb_id) {
  //  var contact = this.contacts.find(
  //                      function(contact){ 
  //                        return contact.get('third_party_id')==fb_id;
  //                      });

  //  this.contacts.remove(contact);
  //  this.reset();
  //},   

  //// Fired when the user cancels an invite
  ////
  //inviteCancelled: function() {
  //  $(this.queryEl).focus();
  //}, 

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
        "style-:style_id/friends" : "friends",
        ":fragment" : "unknown"
      },

      // Display styles tab
      //
      styles: function() {
        self.hideSubViews();
        $(self.stylesContainerEl).show();
      },

      // Display friends after a style is chosen
      //
      friends: function(style) {
        self.hideSubViews();
        $(self.friendsContainerEl).show();
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
    analytics.inviteView(this.source);

    if(helpers.isOnboarding)
      analytics.inviteViewOnboarding();

    analytics.checkForEmailClickedEvent(this.source);
  }

});
