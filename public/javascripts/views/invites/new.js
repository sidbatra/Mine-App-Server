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

    this.friendsView = new Denwen.Partials.Invites.Friends(
                            {el:$('#container')});

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

  // Fire tracking events
  //
  setAnalytics: function() {
    analytics.inviteView(this.source);

    if(helpers.isOnboarding)
      analytics.inviteViewOnboarding();

    analytics.checkForEmailClickedEvent(this.source);
  }

});
