// Partial for displaying and fetching tumblr permissions 
//
Denwen.Partials.Settings.Tumblr = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.permissions = 'tumblr_permissions';
    this.setting = new Denwen.Models.Setting({id:this.permissions});
  },

  // Show the tumblr auth popup 
  //
  showAuthDialog: function() {
    var self = this;
    var oauthWindow = window.open(
                              '/tumblr/authenticate', 
                              'Tumblr Authorization', 
                              'width=800, height=600');

    var oauthInterval = window.setInterval(function(){
                                  if(oauthWindow.closed) {
                                    window.clearInterval(oauthInterval);
                                    self.fetchSettings();
                                  }
                                },1000);
  },

  // Fetch updated tumblr permissions from the server 
  //
  fetchSettings: function() {
    var self = this;

    this.setting.fetch({
        success:  function(setting){self.fetched();},
        error:    function(setting,error){}
        });
  },

  // Fired when the updated settings are fetched
  //
  fetched: function() {
    if(this.setting.get('status')) {
      var keys = {};
      keys[this.permissions] = true;

      Denwen.H.currentUser.get('setting').set(keys);

      Denwen.Track.action("Tumblr Authorization Accepted");
      this.trigger(Denwen.Partials.Settings.Tumblr.Callback.AuthAccepted);
    }
    else {
      Denwen.Track.action("Tumblr Authorization Rejected");
      this.trigger(Denwen.Partials.Settings.Tumblr.Callback.AuthRejected);
    }
  }

});

// Define callbacks.
//
Denwen.Partials.Settings.Tumblr.Callback = {
  AuthAccepted: 'tumblrAuthAccepted',
  AuthRejected: 'tumblrAuthRejected'
}
