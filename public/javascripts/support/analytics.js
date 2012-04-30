// Abstracts the analytics service for a consistent interface
//
Denwen.Analytics = Backbone.Model.extend({

  // Constructor logic
  //
  initialize: function() {
  },

  // Track the version number of the application
  //
  trackVersion: function(version) {
    mpq.register({'Version' : 'v' + version});
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

  // User rejects the additional facebook permissions
  //
  facebookPermissionsRejected: function() {
    mpq.track("Facebook Permissions Rejected");
  },

  // User accepts the additional facebook permissions
  //
  facebookPermissionsAccepted: function() {
    mpq.track("Facebook Permissions Accepted");
  },

  // Test if the given source indicates that the user came from
  // an email and fire an special email clicked tracking event
  //
  checkForEmailClickedEvent: function(source) {
    if(source.slice(0,6) == 'email_')
      this.emailClicked(source.slice(6,source.length));
  },

  // User visits the site from an email
  //
  emailClicked: function(source) {
    mpq.track("Email Clicked", {'Source' : source});
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

  // User searches a product
  //
  productSearched: function(query,queryType,mode) {
    mpq.track("Searched a product", 
      {
        'query':query,
        'Mode':mode,
        'Type':queryType});
  },

  // Fired when an image selected by the user is broken
  //
  productImageBroken: function(mode) {
    mpq.track("Product Image Broken",{'Mode':mode});
  },

  // User cancels product search
  //
  productSearchCancelled: function(source) {
    mpq.track("Product Cancelled",{'Source':source});
  },

  // User selects a product
  //
  productSearchCompleted: function(mode) {
    mpq.track("Product Selected",{'Mode':mode});
  },

  // Validation exception 
  //
  purchaseException: function(type,mode) {
    mpq.track("Purchase Exception",{'type':type,'Mode':mode});
  },

  // User creates a purchase
  //
  purchaseCreated: function() {
    mpq.track("Purchase Created");
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

