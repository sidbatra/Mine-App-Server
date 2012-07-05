// Partial for displaying and fetching facebook permission 
//
Denwen.Partials.Settings.FBPublishPermissions = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.permissions  = Denwen.Settings.FbPublishPermissions; 
    this.setting      = new Denwen.Models.Setting({id:this.permissions});
  },

  // Show the facebook login dialog with extra permissions
  //
  showPermissionsDialog: function() {
    var self = this;

    FB.login(function(response) {
      self.fetchSettings();
    },{scope:'publish_actions'});  
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

      Denwen.Track.action("Facebook Permissions Accepted",{
        "Permissions":this.permissions});

      this.trigger(
        Denwen.Partials.Settings.FBPublishPermissions.Callback.Accepted);
    }
    else {
      Denwen.Track.action("Facebook Permissions Rejected",{
        "Permissions":this.permissions});

      this.trigger(
        Denwen.Partials.Settings.FBPublishPermissions.Callback.Rejected);
    }
  }

});

// Define callbacks.
//
Denwen.Partials.Settings.FBPublishPermissions.Callback = {
  Accepted: 'fbPermissionsAccepted',
  Rejected: 'fbPermissionsRejected'
}
