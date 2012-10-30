Denwen.Partials.Auth.Yahoo = Backbone.View.extend({

  initialize: function() {
    this.auth     = Denwen.Settings.YahooAuth; 
    this.setting  = new Denwen.Models.Setting({id:this.auth});
  },

  showAuthDialog: function() {
    var self = this;
    var authWindow = Denwen.H.popup('/auth/yahoo?usage=popup',800,600);
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

      Denwen.Track.action("Yahoo Authorization Accepted");
      this.trigger(Denwen.Partials.Auth.Yahoo.Callback.AuthAccepted);
    }
    else {
      Denwen.Track.action("Yahoo Authorization Rejected");
      this.trigger(Denwen.Partials.Auth.Yahoo.Callback.AuthRejected);
    }
  }

});

Denwen.Partials.Auth.Yahoo.Callback = {
  AuthAccepted: 'yhAuthAccepted',
  AuthRejected: 'yhAuthRejected'
}


