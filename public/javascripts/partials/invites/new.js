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
    this.buttonEl   = '#post_invite_' + this.recipient.get('id');

    this.fbPermissionsRequired = 'fb_extended_permissions';

    this.fbSettings = new Denwen.Partials.Settings.Facebook({
                            permissions : this.fbPermissionsRequired});

    this.fbSettings.bind(
      Denwen.Partials.Settings.Facebook.Callback.PermissionsAccepted,
      this.fbPermissionsAccepted,
      this);

    this.fbSettings.bind(
      Denwen.Partials.Settings.Facebook.Callback.PermissionsRejected,
      this.fbPermissionsRejected,
      this);

    if(!this.recipient.get('invited'))
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

  // Fired when fb permissions are accepted 
  //
  fbPermissionsAccepted: function() {
    this.sendInvite();
  },

  // Fired when fb permissions are rejected
  //
  fbPermissionsRejected: function() {
    this.stopLoading();
    Denwen.Drawer.error("Please allow Facebook permissions to send invites.");
  },

  // Fired when the user wants to send the invite
  //
  prepareToInvite: function() {

    if(Denwen.H.currentUser.get('setting').get(this.fbPermissionsRequired)) {
      this.sendInvite();
    }
    else { 
      this.startLoading(); 
      this.fbSettings.showPermissionsDialog();
    }

    this.startLoading();

    Denwen.Track.action("Invite Initiated");
  },

  // Send invite request to the server
  //
  sendInvite: function() {
    var self = this;

    var invite = new Denwen.Models.Invite({
                      recipient_id: this.recipient.get('third_party_id'),
                      platform: Denwen.InvitePlatform.Facebook,
                      recipient_name: this.recipient.get('name')});

    invite.save({},{
      success: function(model) {self.inviteCreated()},
      error: function(model,error) {self.inviteFailed()}}); 
  },

  // Invite created
  //
  inviteCreated: function() {
    this.recipient.set({'invited':true});
    this.stopLoading();

    $(this.buttonEl).addClass('pushed');
    $(this.buttonEl).unbind('click');

    Denwen.Track.action("Invite Created");
  },

  // Invite fails to create
  //
  inviteFailed: function() {
    this.stopLoading();
  }

});
