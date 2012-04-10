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
                      'fbSettingsFetched',
                      this.fbSettingsFetched,
                      this);

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

  // Fired when the updated fb permissions settings
  // are fetched
  //
  fbSettingsFetched: function() {

    if(Denwen.H.currentUser.get('setting').get(this.fbPermissionsRequired)) {
      Denwen.Track.facebookPermissionsAccepted();
      this.sendInvite();
    }
    else {
      this.stopLoading();
      Denwen.Drawer.error("Please allow Facebook permissions to send invites.");
      Denwen.Track.facebookPermissionsRejected();
    }
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
    this.stopLoading();

    $(this.buttonEl).addClass('pushed');
    $(this.buttonEl).unbind('click');

    Denwen.Track.inviteCompleted();
  },

  // Invite fails to create
  //
  inviteFailed: function() {
    this.stopLoading();
    console.log("error in sending invite");
  }

});
