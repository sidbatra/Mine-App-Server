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
  
  // Track the page the user landed on
  //
  userLandsOn: function(page) {
    mpq.register_once({'landed_on' : page}); 
  },

  // User signs in
  //
  userLogin: function() {
    mpq.track("User Logged In Again");
  },

  // User clicks the invite friends button
  //
  inviteSelected: function(type) {
    mpq.track("Invite Clicked", {'type':type});
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
  },
  
  // User cancels invite
  //
  inviteCancelled: function() {
    mpq.track("Invite Cancelled");
  },

  // User picks a friend for inviting 
  //
  inviteFriendPicked: function() {
    mpq.track("Invite Friend Picked");
  },

  // User searches a friend for inviting 
  //
  friendSearched: function(query) {
    mpq.track("Friend Searched", {'query':query});
  },

  // User cancels a friend search 
  //
  friendSearchCancelled: function() {
    mpq.track("Friend Search Cancelled"); 
  },

  // User updates a puchase
  //
  purchaseUpdated: function(puchaseID) {
    mpq.track("Puchase Updated");
  },

  // User clicks purchase to visit the original link
  //
  purchaseClicked: function() {
    mpq.track("Purchase Clicked");
  },

  // User deletes a purchase
  //
  purchaseDeleted: function() {
    mpq.track("Purchase Deleted");
  },

  // Page view on user profile
  //
  userProfileView: function(source,id) {
     mpq.track(
      'User Profile View',
      {
      'source'    : source,
      'id'        : id
      });
  },

  // User views the settings page
  //
  settingsView: function(source) {
    mpq.track('Settings View',{'Source' : source});
  },

  // User turns on a setting
  //
  settingTurnedOn: function(name) {
    mpq.track('Setting Turned On',{'Name' : name});
  },

  // User turns off a setting
  //
  settingTurnedOff: function(name) {
    mpq.track('Setting Turned Off',{'Name' : name});
  },

  // User updates settings
  //
  settingsUpdated: function() {
    mpq.track('Settings Updated');
  },

  // User visits the settings page with an unsubscription in mind
  //
  unsubscribeInitiated: function(source) {
    mpq.track("Unsubscribe Initiated", {'Source' : source});
  },

  // Page view on purchase profile
  //
  purchaseProfileView: function(source,id) {
     mpq.track(
      'Purchase Profile View',
      {
        'source'  : source,
        'id'      : id
      });
  },

  // Page view on the invite page
  //
  inviteView: function(source) {
     mpq.track('Invite View',{'source' : source});
  },

  // User opens edit purchase page
  //
  purchaseEditView: function(purchase_id,source) {
    mpq.track("Purchase Editing View", 
      {
      'Purchase ID'  : purchase_id,
      'User ID'     : Denwen.H.currentUserID(),
      'Source'      : source
      });
  }

});

