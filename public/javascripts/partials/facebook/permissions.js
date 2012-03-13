// Dialog for asking additional facebook permissions 
//
Denwen.Partials.Facebook.Permissions = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
  },

  // Show the facebook login dialog with extra permissions
  //
  show: function() {
    var self = this;

    FB.login(function(response) {
     self.trigger('fbPermissionsDialogClosed'); 
    },{scope: CONFIG['fb_extended_permissions']});  
  }

});
