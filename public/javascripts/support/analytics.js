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
  // id - The integer database id of the user.
  // name - The String ull name pf the user.
  // email - The String email of the user.
  // age - The Integer age of the user.
  // gender - The String gender of the user. Male or Female.
  // createdAt - The String timestamp of when the user joined.
  //
  // Returns nothing.
  user: function(id,name,email,age,gender,createdAt) {
    //mixpanel.identify(id);
    mixpanel.name_tag(email);

    mixpanel.register({"Age" : age});
    mixpanel.register_once({"Gender" : gender});

    //mixpanel.people.set({
    //  "$email": email,
    //  "$created": createdAt,
    //  "$name": name,
    //  "Gender": gender,
    //  "Age": age});
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
  },

  // Public. Track clicks to source urls of purchases.
  //
  // source - The String name of the source where the click originated.
  //
  purchaseURLVisit: function(source) {
    mixpanel.track("Purchase URL Clicked", {"Source" : source});
  }

});

