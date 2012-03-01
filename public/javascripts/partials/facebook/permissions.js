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
    FB.login(function(response) {
      console.log("trigger some action");
    },{scope: 'publish_stream'});  
  }

});
