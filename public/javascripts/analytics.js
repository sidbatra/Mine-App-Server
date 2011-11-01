// Abstracts the analytics service for a consistent interface
//
Denwen.Analytics = Backbone.Model.extend({

  // Constructor logic
  //
  initialize: function() {
  },

  // Identify a user and associate a friendly name tag
  //
  identifyUser: function(email,name) {
    mpq.identify(email);
    mpq.name_tag(name);
  },
  
  // Track the page the user landed on
  //
  userLandsOn: function(page) {
    mpq.register_once({'landed_on' : page}); 
  },

  // User signs in
  userLogin: function() {
    mpq.track("User Logged In");
  },

  // User creates a product
  //
  productCreated: function() {
    mpq.track("Item Created");
  },

  // User creates a comment
  //
  commentCreated: function() {
    mpq.track("Comment Created");
  },

  // User clicks the invite friends button
  //
  inviteSelected: function() {
    mpq.track("Invite Clicked");
  },

  // User opens invite dialog and rejects it
  //
  inviteRejected: function() {
    mpq.track("Invite Rejected");
  },
  
  // User opens invite dialog and completes it
  //
  inviteCompleted: function() {
    mpq.track("Invite Completed");
  }

});
