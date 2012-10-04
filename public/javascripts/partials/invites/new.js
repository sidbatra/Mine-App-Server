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

    this.handle     = this.options.handle; 

    this.recipient  = this.options.recipient;
    this.buttonEl   = '#post_invite_' + this.recipient.get('id');

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

  // Fired when the user wants to send the invite
  //
  prepareToInvite: function() {
    this.startLoading();
    this.showSendDialog();

    Denwen.Track.action("Invite Initiated");
  },

  // Show facebook send message dialog 
  //
  showSendDialog: function() {
    var self    = this;
    var url     = 'http://getmine.com/invites/' + this.handle;
    var method  = Denwen.Device.get("is_phone") ? 'apprequests' : 'send'; 
    var display = Denwen.Device.get("is_phone") ? 'touch' : 'popup';
    var message = 'Join me on Mine';

    FB.ui({method: method, 
      display: display,
      link: url,
      message: message,
      to: this.recipient.get('third_party_id')}, 
      function(response) {self.sendCallback(response)});
  },

  // Handle callback from the facebook send dialog
  //
  sendCallback: function(response) {
    if(!response) {
      Denwen.Track.action("Invite Rejected");
      this.stopLoading();
    }
    else {
      this.sendInvite();
    } 
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

    Denwen.Track.action("Invite Created",{"Source":"facebook"});
  },

  // Invite fails to create
  //
  inviteFailed: function() {
    this.stopLoading();
  }

});
