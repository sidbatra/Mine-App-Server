// Dialog for inviting facebook friends 
//
Denwen.FacebookInviteView = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self  = this;
    this.id   = this.options.id;

    $(this.id).click(function(){self.showInviteDialog();});
  },

  // Handle callback from the invite dialog
  //
  requestCallback: function(response) {
    if(!response) {
      analytics.inviteRejected();
    }
    else {
      analytics.inviteCompleted();
    }
  },

  // Show facebook invite dialog 
  //
  showInviteDialog: function() {
    FB.ui({method: 'apprequests',
      message: 'Come join me on Felvy! An online closet for everything you own.',
      title: 'Invite Your Facebook Friends to Felvy'
    }, this.requestCallback);

    analytics.inviteSelected();
  }
});
