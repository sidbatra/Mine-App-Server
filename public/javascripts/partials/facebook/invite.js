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

    $('body').find('#fb_invite_link').click(
              function(e){self.showMultiInviteDialog();});

    $('body').find('#fb_single_invite_link').click(
              function(e){self.showSingleInviteDialog(e);});
  },

  // Save the sent invites to the server
  //
  save: function(response) {
    var invites = response['to'];

    new Denwen.Partials.Invites.BatchInvite({fb_user_ids : invites});
    analytics.inviteCompleted(invites.length);
    
    return invites;
  },

  // Handle callback from the single invite dialog
  //
  inviteCallback: function(response) {
    if(!response) {
      analytics.inviteRejected();
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
      analytics.inviteRejected();
    }
    else {
      this.save(response);
    }
  },

  // Show facebook single invite dialog 
  //
  showSingleInviteDialog: function(e) {
    var self  = this;
    var fb_id = $(e.target).attr('fb_id');

    FB.ui({method: 'apprequests',
      message: "Come check out my online closet!",
      title: 'Compare closets with friends',
      to: fb_id}, 
      function(response) {self.inviteCallback(response)});

    analytics.inviteSelected('single');
  },

  // Show facebook multi invite dialog 
  //
  showMultiInviteDialog: function() {
    var self = this;

    FB.ui({method: 'apprequests',
      message: "Come check out my online closet!",
      title: 'Compare closets with friends'}, 
      function(response) {self.multiInviteCallback(response)});

    analytics.inviteSelected('multi');
  }

});
