// Partial for tumblr authorization 
//
Denwen.Partials.Auth.Tumblr = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.auth     = Denwen.Settings.TumblrAuth;
    this.setting  = new Denwen.Models.Setting({id:this.auth});
  },

  // Show the tumblr auth popup 
  //
  showAuthDialog: function() {
    var self = this;
    var oauthWindow = Denwen.H.popup('/tumblr/authenticate',800,600);
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
      keys[this.auth] = true;

      Denwen.H.currentUser.get('setting').set(keys);

      Denwen.Track.action("Tumblr Authorization Accepted");
      this.trigger(Denwen.Partials.Auth.Tumblr.Callback.AuthAccepted);
    }
    else {
      Denwen.Track.action("Tumblr Authorization Rejected");
      this.trigger(Denwen.Partials.Auth.Tumblr.Callback.AuthRejected);
    }
  }

});

// Define callbacks.
//
Denwen.Partials.Auth.Tumblr.Callback = {
  AuthAccepted: 'tumblrAuthAccepted',
  AuthRejected: 'tumblrAuthRejected'
}
