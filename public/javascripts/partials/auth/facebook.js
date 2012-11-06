// Partial for facebook authorization 
//
Denwen.Partials.Auth.Facebook = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.auth     = Denwen.Settings.FbAuth; 
    this.setting  = new Denwen.Models.Setting({id:this.auth});
  },

  // Show the facebook auth popup 
  //
  showAuthDialog: function() {
    var self = this;
    var authWindow = Denwen.H.popup('/facebook/authenticate?usage=popup',800,600);
    var authInterval = window.setInterval(function(){
                                  if(authWindow.closed) {
                                    window.clearInterval(authInterval);
                                    self.fetchSettings();
                                  }
                                },1000);
  },

  // Fetch updated facebook permissions from the server 
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

      Denwen.Track.action("Facebook Authorization Accepted");
      this.trigger(Denwen.Partials.Auth.Facebook.Callback.AuthAccepted);
    }
    else {
      Denwen.Track.action("Facebook Authorization Rejected");
      this.trigger(Denwen.Partials.Auth.Facebook.Callback.AuthRejected);
    }
  }

});

// Define callbacks.
//
Denwen.Partials.Auth.Facebook.Callback = {
  AuthAccepted: 'fbAuthAccepted',
  AuthRejected: 'fbAuthRejected'
}
