// Dialog for inviting facebook friends 
//
Denwen.Partials.Facebook.Invite = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
  },

  // Hooked up the FB dialog on all designated links
  //
  hookUp: function() {
    var self = this;

    $('body').find('#invite_backup_button').click(
              function(e){self.showMultiInviteDialog();});

    $('body').find('#fb_single_invite_link').click(
              function(e){self.showSendDialog(e);});

    /*$('body').find('#fb_single_invite_link').click(
              function(e){self.showSingleInviteDialog(e);});*/
  },

  // Save the sent invites to the server
  //
  save: function(response) {
    var invites = response['to'];

    new Denwen.Partials.Invites.BatchInvite({fb_user_ids : invites});
    Denwen.Track.inviteCompleted(invites.length);
    
    return invites;
  },

  // Handle callback from the single invite dialog
  //
  inviteCallback: function(response) {
    if(!response) {
      Denwen.Track.inviteRejected();
      this.trigger('inviteCancelled');
    }
    else {
      var invites = this.save(response);
      this.trigger('inviteCompleted',invites[0]);
    }
  },

  // Handle callback from the multi invite dialog
  //
  multiInviteCallback: function(response) {
    if(!response) {
      Denwen.Track.inviteRejected();
    }
    else {
      this.save(response);
    }
  },

  // Handle callback from the send dialog
  //
  sendCallback: function(response) {
    if(!response) {
      Denwen.Track.inviteRejected();
      this.trigger('inviteCancelled');
    }
    else {
      new Denwen.Partials.Invites.BatchInvite({fb_user_ids : new Array(this.fbID)});
      Denwen.Track.inviteCompleted(1);
      this.trigger('inviteCompleted',this.fbID);
    } 
  },

  // Show facebook send message dialog 
  //
  showSendDialog: function(e) {
    var self  = this;
    this.fbID = $(e.target).attr('fb_id');

    FB.ui({method: 'send',
      message: CONFIG['fb_invite_msg'], 
      title: CONFIG['fb_invite_title'],
      link: 'http://oncloset.com/home/fb',
      to: this.fbID}, 
      function(response) {self.sendCallback(response)});

    Denwen.Track.inviteSelected('single');
  },

  // Show facebook single invite dialog 
  //
  showSingleInviteDialog: function(e) {
    var self  = this;
    var fb_id = $(e.target).attr('fb_id');

    FB.ui({method: 'apprequests',
      message: CONFIG['fb_invite_msg'], 
      title: CONFIG['fb_invite_title'],
      to: fb_id}, 
      function(response) {self.inviteCallback(response)});

    Denwen.Track.inviteSelected('single');
  },

  // Show facebook multi invite dialog 
  //
  showMultiInviteDialog: function() {
    var self = this;

    FB.ui({method: 'apprequests',
      message: CONFIG['fb_invite_msg'], 
      title: CONFIG['fb_invite_title']},
      function(response) {self.multiInviteCallback(response)});

    Denwen.Track.inviteSelected('multi');
  }

});
