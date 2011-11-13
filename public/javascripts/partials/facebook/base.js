// Initializes and loads the fb javascript sdk
// and is used whenever a fb feature is required on the page
//
Denwen.Partials.Facebook.Base = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self  = this;
    $(document).ready(function(){self.loadFBJavascriptSDK();});  
  },

  // Loads and initializes fb javascript SDK
  //
  loadFBJavascriptSDK: function() {
    (function(d, s, id) {
      var js, fjs = d.getElementsByTagName(s)[0];
      if (d.getElementById(id)) {return;}
      js = d.createElement(s); js.id = id;
      js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=245230762190915";
      fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'facebook-jssdk'));
  }
});
