// Partial for displaying the final invite confirmation and creating invites
//
Denwen.Partials.Invites.New.Finish = Backbone.View.extend({
  
  // Setup event handlers
  //
  events: {
    "click #send_invite"   : "prepareToSendInvite",
    "click #cancel_invite" : "cancelInvite"
  },

  // Constructor logic
  //
  initialize: function() {
    this.loadClass = "load";

    this.name   = "";
    this.fbID   = "";
    this.byline = "";

    this.largeNameEl    = '#friend_name_large';
    this.smallNameEl    = '#friend_name_small';
    this.bylineEl       = '#friend_byline';
    this.imageEl        = '#friend_image';
    this.actionsAreaEl  = '#actions_area';

    this.setting = new Denwen.Models.Setting({id:'publish_stream'}); 
    this.setting.fetch();

    this.fbPermissionsBox = new Denwen.Partials.Facebook.Permissions();
    this.fbPermissionsBox.bind(
          'fbPermissionsDialogClosed',
          this.fbPermissionsDialogClosed,
          this);
  },

  // Fired just before the view is coming into focus
  //
  display: function(byline,name,fbID) {
    this.stopLoading();

    this.name   = name;
    this.fbID   = fbID;
    this.byline = byline;

    var firstName = name.split(' ')[0];

    $(this.largeNameEl).html(firstName);
    $(this.smallNameEl).html(firstName);
    $(this.bylineEl).html(byline);
    $(this.imageEl).css(
      "background-image",
      "url('https://graph.facebook.com/" + fbID + "/picture?type=large')");

    analytics.inviteFriendPicked();
  },

  // Enter loading state
  //
  startLoading: function() {
    $(this.actionsAreaEl).addClass(this.loadClass);
  },

  // Exit loading state
  //
  stopLoading: function() {
    $(this.actionsAreaEl).removeClass(this.loadClass);
  },

  // Fired when the user allows or skips the facebook
  // permission dialog
  //
  fbPermissionsDialogClosed: function() {
    var self = this;

    this.startLoading();
    this.setting.fetch({
          success:  function(setting){self.updatedSettingsFetched();},
          error:    function(setting,error){}
          });
  },

  // Fired when the updated permissions settings
  // are fetched
  //
  updatedSettingsFetched: function() {
    
    if(this.setting.get('status')) {
      analytics.facebookPermissionsAccepted();
      this.sendInvite();
    }
    else {
      this.stopLoading();
      dDrawer.error("Please allow Facebook permissions to send an invite.");
      analytics.facebookPermissionsRejected();
    }
  },

  // Fired when the user wants to send the invite
  //
  prepareToSendInvite: function() {

    if(this.setting.get('status'))
      this.sendInvite();
    else 
      this.fbPermissionsBox.show();
  },

  // Send invite request to the server
  //
  sendInvite: function() {
    this.startLoading();

    var self = this;

    var invite = new Denwen.Models.Invite({
                      recipient_id: this.fbID,
                      platform: Denwen.InvitePlatform.Facebook,
                      recipient_name: this.name,
                      byline: this.byline});

    invite.save({},{
      success: function(model) {self.inviteCreated()},
      error: function(model,error) {self.inviteFailed()}});
  },

  // Invite created
  //
  inviteCreated: function() {
    window.location.hash = Denwen.InviteNewHash.Styles;
    dDrawer.success("Invite sent successfully.");
    analytics.inviteCompleted();
  },

  // Invite fails to create
  //
  inviteFailed: function() {
  },

  // User cancels invite
  //
  cancelInvite: function() {
    window.location.hash = Denwen.InviteNewHash.Styles;
    analytics.inviteCancelled();
  }

});
