// Partial for displaying and fetching facebook permission 
//
Denwen.Partials.Settings.Facebook = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.permissions  = this.options.permissions;
    this.setting      = new Denwen.Models.Setting({id:this.permissions});
  },

  // Show the facebook login dialog with extra permissions
  //
  showPermissionsDialog: function() {
    var self = this;

    FB.login(function(response) {
      self.fetchSettings();
    },{scope: CONFIG[self.permissions]});  
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

      this.setting = new Denwen.Models.Setting({
                            id     : this.permissions,
                            value  : true});

      this.setting.save({},{
        success: function(model) {},
        error: function(model,error) {}}); 

      var keys = {};
      keys[this.permissions] = true;

      Denwen.H.currentUser.get('setting').set(keys);

      Denwen.Track.facebookPermissionsAccepted();
      this.trigger(Denwen.Partials.Settings.Facebook.Callback.PermissionsAccepted);
    }
    else {
      Denwen.Track.facebookPermissionsRejected();
      this.trigger(Denwen.Partials.Settings.Facebook.Callback.PermissionsRejected);
    }
  }

});

// Define callbacks.
//
Denwen.Partials.Settings.Facebook.Callback = {
  PermissionsAccepted: 'fbPermissionsAccepted',
  PermissionsRejected: 'fbPermissionsRejected'
}
