// Abstracts the analytics service for a consistent interface
//
Denwen.Analytics = Backbone.Model.extend({

  // Constructor logic
  //
  initialize: function() {
  },

  // Public. Wrapped around mixpanel's track method.
  //
  // name - The String to be tracked.
  // options - The Hash of associated options with the 
  //            action. (default: {})
  //
  action: function(name,options) {
    if(options == undefined)
      options = {};

    mixpanel.track(name,options);
  },

  // Public. Track useful attributes about the current user.
  //
  // email - The String email of the user.
  // age - The Integer age of the user.
  // gender - The String gender of the user. Male or Female.
  //
  user: function(email,age,gender) {
    mixpanel.name_tag(email);

    mixpanel.register_once({"Age" : age});
    mixpanel.register_once({"Gender" : gender});
  },

  // Public. Track the version number of the application as a variable.
  //
  // version - The String in a MAJOR.MINOR.PATCH format.
  //
  version: function(version) {
    mixpanel.register({"Version" : 'v' + version.slice(0,version.length-2)});
  },

  // Public. Track email clicks if the given source indicates that 
  // the user landed on a page via an email.
  //
  // source - The String source for a page.
  //
  isEmailClicked: function(source) {
    if(source.slice(0,6) == 'email_')
      this.emailClicked(source.slice(6,source.length));
  },

  // Public. Track links clicked from an email.
  //
  // source - The String source for which email link was clicked.
  //
  emailClicked: function(source) {
    mixpanel.track("Email Clicked", {"Source" : source});
  },

  // Public. Track validation errors during the creation
  // of a purchase.
  //
  // name - The String name of the error.
  //
  purchaseValidationError: function(name) {
    mixpanel.track("Purchase Validation Error",{'Name' : name});
  },
  
  // Public. Track origin of the user.
  //
  origin: function(origin) {
    mixpanel.register_once({"Origin" : origin});
  }

});

