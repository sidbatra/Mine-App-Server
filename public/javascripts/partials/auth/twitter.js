// Partial for twitter authorization 
//
Denwen.Partials.Auth.Twitter = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.auth     = Denwen.Settings.TwAuth; 
    this.setting  = new Denwen.Models.Setting({id:this.auth});
  },

  // Show the twitter auth popup 
  //
  showAuthDialog: function() {
    var self = this;
    var oauthWindow = Denwen.H.popup('/twitter/authenticate?usage=popup',800,600);
    var oauthInterval = window.setInterval(function(){
                                  if(oauthWindow.closed) {
                                    window.clearInterval(oauthInterval);
                                    self.fetchSettings();
                                  }
                                },1000);
  },

  // Fetch updated twitter permissions from the server 
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

      Denwen.Track.action("Twitter Authorization Accepted");
      this.trigger(Denwen.Partials.Auth.Twitter.Callback.AuthAccepted);
    }
    else {
      Denwen.Track.action("Twitter Authorization Rejected");
      this.trigger(Denwen.Partials.Auth.Twitter.Callback.AuthRejected);
    }
  }

});

// Define callbacks.
//
Denwen.Partials.Auth.Twitter.Callback = {
  AuthAccepted: 'twAuthAccepted',
  AuthRejected: 'twAuthRejected'
}
