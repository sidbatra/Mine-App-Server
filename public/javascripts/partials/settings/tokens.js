Denwen.Partials.Settings.Tokens = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.setting = new Denwen.Models.Setting({id:'tokens'});
  },

  // Fetch status of tokens from server.
  //
  fetchStatus: function() {
    var self = this;

    this.setting.fetch({
        success:  function(setting){self.fetched();},
        error:    function(setting,error){}
        });
  },

  // Fired when the token status is fetched
  //
  fetched: function() {
    if(!this.setting.get('facebook')) {

      var keys = {};
      keys['fb_publish_permissions'] = false;

      Denwen.H.currentUser.get('setting').set(keys);

      this.trigger(Denwen.Partials.Settings.Tokens.Callback.FBDead);
    }
    else {
      this.trigger(Denwen.Partials.Settings.Tokens.Callback.FBAlive);
    }
  }

});

// Define callbacks.
//
Denwen.Partials.Settings.Tokens.Callback = {
  FBAlive: 'fbAlive',
  FBDead: 'fbDead'
}

