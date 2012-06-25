Denwen.Partials.Settings.FBAccessToken = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.setting  = new Denwen.Models.Setting({
                          id:Denwen.Settings.FbAccessToken
                        });

    this.fetchStatus();
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
    if(!this.setting.get('status')) {

      var keys = {};

      keys[Denwen.Settings.FbAuth]                = false;
      keys[Denwen.Settings.FbPublishPermissions]  = false;
      keys[Denwen.Settings.FbExtendedPermissions] = false;

      Denwen.H.currentUser.get('setting').set(keys);
    }
  }

});
