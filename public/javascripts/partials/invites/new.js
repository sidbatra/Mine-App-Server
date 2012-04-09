// Partial for sending an individual invite and reflecting 
// corresponding UI changes
//
Denwen.Partials.Invites.New = Backbone.View.extend({
  
  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self        = this; 

    this.recipient  = this.options.recipient;
    this.buttonEl   = '#invite_button_' + this.recipient.get('id');

    $(this.buttonEl).click(function(){self.prepareToInvite();});
  },

  // Enter loading state
  //
  startLoading: function() {
    $(this.buttonEl).addClass('load');
  },

  // Exit loading state
  //
  stopLoading: function() {
    $(this.buttonEl).removeClass('load');
  },

  // Fired when the user wants to send the invite
  //
  prepareToSendInvite: function() {
    
    /*
    if(this.setting.get('status'))
      this.sendInvite();
    else 
      this.fbPermissionsBox.show();*/
  },

  // Send invite request to the server
  //
  sendInvite: function() {
    /*
    this.startLoading();

    var self = this;

    var invite = new Denwen.Models.Invite({
                      recipient_id: this.fbID,
                      platform: Denwen.InvitePlatform.Facebook,
                      recipient_name: this.name});

    invite.save({},{
      success: function(model) {self.inviteCreated()},
      error: function(model,error) {self.inviteFailed()}}); */
  },

  // Invite created
  //
  inviteCreated: function() {
    Denwen.Drawer.success("Invite sent successfully.");
    Denwen.Track.inviteCompleted();
  },

  // Invite fails to create
  //
  inviteFailed: function() {
  }

});
