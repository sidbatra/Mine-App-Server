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

    this.stylesContainerEl  = '#styles_container';
    this.friendsContainerEl = '#friends_container';

    this.friendsView = new Denwen.Partials.Invites.New.Friends(
                            {el:$('#container')});

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
        "friend-with-style-:style" : "friends"
      },

      // Display friends after a style is chosen
      //
      friends: function(style) {
        self.hideSubViews();
        $(self.friendsContainerEl).show();
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
