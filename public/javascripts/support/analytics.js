// Abstracts the analytics service for a consistent interface
//
Denwen.Analytics = Backbone.Model.extend({

  // Constructor logic
  //
  initialize: function() {
  },

  // Identify a user and associate a friendly name tag
  //
  identifyUser: function(email,age,gender) {
    mpq.name_tag(email);
    mpq.register_once({'age' : age}); 
    mpq.register_once({'Gender' : gender}); 
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

  // User created
  //
  userCreated: function() {
    mpq.track("$born");
    mpq.track("User Logged In");
  },

  // User initiates byline editing
  //
  bylineEditingSelected: function() {
    mpq.track("Byline Editing Clicked");
  },

  // User cancels byline editing
  //
  bylineEditingCancelled: function() {
    mpq.track("Byline Editing Cancelled");
  },

  // User successfully edits byline
  //
  bylineEditingCompleted: function() {
    mpq.track("Byline Editing Completed");
  },

  // User picks the store where they shop at 
  //
  shoppingsCreated: function() {
    mpq.track("Shoppings Created");
  },

  // User turns on a product
  //
  productTurnedOn: function() {
    mpq.track("Product Turned On");
  },

  // User turns off a product
  //
  productTurnedOff: function() {
    mpq.track("Product Turned Off");
  },

  // Modal view all selected for the given type
  //
  viewAllSelected: function(type) {
    mpq.track("View All "+ type);
  },

  // User creates a following
  //
  followingCreated: function(followedID) {
    mpq.track("Following Created",{
          'Followed ID'  : followedID,
          'User ID'      : Denwen.H.currentUserID()});
  },

  // User destroys a following
  //
  followingDestroyed: function(followedID) {
    mpq.track("Following Destroyed",{
          'Followed ID'  : followedID,
          'User ID'      : Denwen.H.currentUserID()});
  },

  // User initiates the product ownership process
  //
  ownInitiated: function(source,sourceID,productID) {
    mpq.track('Own Initiated', {
      'Source'          : source,
      'Source ID'       : sourceID,
      'Product ID'      : productID,
      'User ID'         : Denwen.H.currentUserID()});
  },

  // User cancels the product ownership process
  //
  ownCancelled: function(source,sourceID,productID) {
    mpq.track('Own Cancelled', {
      'Source'          : source,
      'Source ID'       : sourceID,
      'Product ID'      : productID,
      'User ID'         : Denwen.H.currentUserID()});
  },

  // User owns a product
  //
  ownCreated: function(source,sourceID,productID) {
    mpq.track('Own Created', {
      'Source'          : source,
      'Source ID'       : sourceID,
      'Product ID'      : productID,
      'User ID'         : Denwen.H.currentUserID()});
  },

  // User wants a product
  //
  wantCreated: function(source,sourceID,productID) {
    mpq.track('Want Created', {
      'Source'          : source,
      'Source ID'       : sourceID,
      'Product ID'      : productID,
      'User ID'         : Denwen.H.currentUserID()});
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

  // User picks a style for a friend he/she is inviting
  //
  inviteStylePicked: function() {
    mpq.track("Invite Style Picked");
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
  productSearchCancelled: function(source,mode) {
    mpq.track("Product Cancelled",{'Source':source,'Mode':mode});
  },

  // User selects a product
  //
  productSearchCompleted: function(mode) {
    mpq.track("Product Selected",{'Mode':mode});
  },

  // Validation exception 
  //
  productException: function(type,mode) {
    mpq.track("Product Exception",{'type':type,'Mode':mode});
  },

  // User creates a product
  //
  productCreated: function() {
    mpq.track("Item Created",{
          'User ID'    : Denwen.H.currentUserID()});
  },

  // User updates a product
  //
  productUpdated: function(productID) {
    mpq.track("Product Updated",{
          'Product ID' : productID,
          'User ID'    : Denwen.H.currentUserID()});
  },

  // User clicks product to visit the original link
  //
  productClicked: function() {
    mpq.track("Product Clicked");
  },

  // User deletes a product
  //
  productDeleted: function() {
    mpq.track("Item Deleted");
  },

  // User picks a store on the store onboarding page 
  //
  storePicked: function() {
    mpq.track("Store Picked");
  },

  // User unpicks a store on the store onboarding page 
  //
  storeUnpicked: function() {
    mpq.track("Store Unpicked");
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

  // A type of user's products are 
  // explictly viewed
  //
  userProductsView: function(type,userID) {
    mpq.track(
      'User ' + type.capitalize() + ' View',{
        'Is Own Profile'  : Denwen.H.isCurrentUser(userID),
        'id'              : userID});
  },

  // A user's followers are viewed
  //
  userFollowersView: function(userID) {
    mpq.track(
      'User Followers View',{
        'Is Own Profile'  : Denwen.H.isCurrentUser(userID),
        'id'              : userID});
  },

  // A user's ifollowers are viewed
  //
  userIFollowersView: function(userID) {
    mpq.track(
      'User IFollowers View',{
        'Is Own Profile'  : Denwen.H.isCurrentUser(userID),
        'id'              : userID});
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

  // A store's products are explicitly viewed
  //
  storeProductsView: function(storeID) {
    mpq.track('Store Products View',{
      'id'        : storeID
    });
  },

  // Page view on store profile
  //
  storeProfileView: function(source,id) {
     mpq.track(
      'Store Profile View',
      {
      'source'    : source,
      'id'        : id
      });
  },

  // Page view on product profile
  //
  productProfileView: function(source,id) {
     mpq.track(
      'Product Profile View',
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

  // Page view on the shoppings new page
  //
  shoppingNewView: function(source) {
     mpq.track(
      'Shopping New View',{'source' : source});
  },

  // Fired when the invite view is opened during onboarding
  //
  inviteViewOnboarding: function() {
    mpq.track("Onboarding Invite View");
  },

  // Page view on the welcome view
  //
  welcomeView: function() {
    mpq.track("Onboarding Welcome");
  },

  // User opens new product page
  //
  productNewView: function(source,suggestionID,suggestionTitle) {
    mpq.track("Creation Template Opened", 
      {
      'source'  : source,
      'Suggestion ID' : 's' + suggestionID,
      'Suggestion Title' : suggestionTitle
      });
  },

  // User lands on stores picker view during onboarding
  //
  onboardingStoresView: function() {
    mpq.track("Onboarding Stores View");
  },

  // User lands on followings view during onboarding
  //
  onboardingFollowingView: function() {
    mpq.track("Onboarding Following View");
  },

  // User lands on product new view during onboarding
  //
  productNewViewOnboarding: function() {
    mpq.track("Onboarding Creation Template Opened");
  },

  // User opens edit product page
  //
  productEditView: function(product_id,source) {
    mpq.track("Product Editing View", 
      {
      'Product ID'  : product_id,
      'User ID'     : Denwen.H.currentUserID(),
      'Source'      : source
      });
  },

  // Style view is opened during onboarding
  //
  styleViewOnboarding: function() {
    mpq.track("Onboarding Style View");
  },

  // Style view is opened outside onboarding
  //
  styleView: function(source) {
    mpq.track("Style New View",{'Source':source});
  },

  // User selects a particular style
  //
  stylePicked: function() {
    mpq.track("Style Picked");
  },

  // Sharing view is opened during onboarding
  //
  shareViewOnboarding: function() {
    mpq.track("Onboarding Share View");
  }

});

