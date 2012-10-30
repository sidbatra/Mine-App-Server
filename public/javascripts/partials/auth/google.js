Denwen.Partials.Auth.Google = Backbone.View.extend({

  initialize: function() {
    this.auth     = Denwen.Settings.GoogleAuth; 
    this.setting  = new Denwen.Models.Setting({id:this.auth});
  },

  showAuthDialog: function() {
    var self = this;
    var authWindow = window.open(
                              '/auth/google?usage=popup', 
                              '', 
                              'width=800, height=600');

    var authInterval = window.setInterval(function(){
                                  if(authWindow.closed) {
                                    window.clearInterval(authInterval);
                                    self.fetchSettings();
                                  }
                                },1000);
  },

  fetchSettings: function() {
    var self = this;

    this.setting.fetch({
        success:  function(setting){self.fetched();},
        error:    function(setting,error){}
        });
  },

  fetched: function() {
    if(this.setting.get('status')) {
      var keys = {};
      keys[this.auth] = true;

      Denwen.H.currentUser.get('setting').set(keys);

      Denwen.Track.action("Google Authorization Accepted");
      this.trigger(Denwen.Partials.Auth.Google.Callback.AuthAccepted);
    }
    else {
      Denwen.Track.action("Google Authorization Rejected");
      this.trigger(Denwen.Partials.Auth.Google.Callback.AuthRejected);
    }
  }

});

Denwen.Partials.Auth.Google.Callback = {
  AuthAccepted: 'goAuthAccepted',
  AuthRejected: 'goAuthRejected'
}

