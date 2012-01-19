// Partial to handle login/signup using facebook sdk 
//
Denwen.Partials.Facebook.Session = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
    "click #fb_login_button"  : "login"
  },

  // Constructor logic
  //
  initialize: function() {
    this.origin = this.options.origin;
  },

  // Fired when the user clicks the login button 
  //
  login: function() {
    var self = this;

    analytics.fbLoginButtonClicked();

    FB.login(function(response) {
      if(response.authResponse) { 
        window.location.href = "http://" + window.location.host + 
                               "/facebook/reply?" + 
                               "access_token=" +
                               response.authResponse.accessToken + 
                               "&source=" + self.origin; 
      }
      else {
        analytics.fbConnectRejected();
      }
    }, {scope: 'email,user_likes,user_birthday'});
  }

});
