// Partial for displaying and fetching facebook permission 
//
Denwen.Partials.Settings.Facebook = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.setting = new Denwen.Models.Setting({id:'publish_stream'});
  },

  // Show the facebook login dialog with extra permissions
  //
  showPermissionsDialog: function() {
    var self = this;

    FB.login(function(response) {
      self.fetchSettings();
    },{scope: CONFIG['fb_extended_permissions']});  
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
      Denwen.H.currentUser.set({'fb_publish_permission':true});

      this.setting = new Denwen.Models.Setting({id:'fb_publish_stream'});

      this.setting.save({},{
        success: function(model) {},
        error: function(model,error) {}}); 
    }

    this.trigger('fbSettingsFetched');
  }

});
