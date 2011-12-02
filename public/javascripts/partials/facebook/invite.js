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

    $('body').find('#fb_single_invite_link').click(
              function(e){self.showInviteDialog(e);});
  },

  // Handle callback from the invite dialog
  //
  requestCallback: function(response) {
    if(!response) {
      analytics.inviteRejected();
      this.trigger('inviteCancelled');
    }
    else {
      var invites = response['to'];
      new Denwen.Partials.Invites.BatchInvite({fb_user_ids : invites});

      analytics.inviteCompleted(1);
      this.trigger('inviteCompleted',invites[0]);
    }
  },

  // Show facebook invite dialog 
  //
  showInviteDialog: function(e) {
    var fb_id = $(e.target).attr('fb_id');

    FB.ui({method: 'apprequests',
      message: "Come check out my online closet!",
      title: 'Compare closets with friends',
      to: fb_id
    }, this.requestCallback.bind(this));

    analytics.inviteSelected();
  }

});
