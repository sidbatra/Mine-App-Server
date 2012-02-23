// Abstracts the analytics service for a consistent interface
//
Denwen.Analytics = Backbone.Model.extend({

  // Constructor logic
  //
  initialize: function() {
  },

  // Identify a user and associate a friendly name tag
  //
  identifyUser: function(email,age) {
    mpq.name_tag(email);
    mpq.register_once({'age' : age}); 
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

  // Collection onboarding previewed in disabled state 
  //
  collectionOnboardingPreviewed: function() {
    mpq.track("Collection Onboarding Previewed");
  },

  // Collection onboarding of a certain type viewed
  //
  collectionOnboardingViewed: function(type) {
    mpq.track("Collection Onboarding Viewed",{'type':type});
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

  // User creates a collection
  //
  collectionCreated: function() {
    mpq.track("Collection Created");
  },

  // User updates a collection
  //
  collectionUpdated: function() {
    mpq.track("Collection Updated");
  },

  // User tried to create a collection with an exception
  // 
  collectionException: function(type) {
    mpq.track("Collection Exception",{'Type' : type});
  },

  // User cancels a collection
  //
  collectionCancelled: function() {
    mpq.track("Collection Cancelled");
  },

  // User deletes a collection
  //
  collectionDeleted: function() {
    mpq.track("Collection Deleted");
  },

  // User starts to type a comment
  //
  commentSelected: function() {
    mpq.track("Comment Selected");
  },

  // User creates a comment
  //
  commentCreated: function(commentableType) {
    mpq.track("Comment Created", {'Commentable Type':commentableType});
  },

  // User creates a following
  //
  followingCreated: function(followedID) {
    mpq.track("Following Created",{
          'Followed ID'  : followedID,
          'User ID'      : helpers.currentUserID()});
  },

  // User destroys a following
  //
  followingDestroyed: function(followedID) {
    mpq.track("Following Destroyed",{
          'Followed ID'  : followedID,
          'User ID'      : helpers.currentUserID()});
  },

  // User creates a like on a collection
  //
  likeCreated: function(source,sourceID,collectionID,collectionUserID) {
    mpq.track('Collection Like Created', {
      'Source'            : source,
      'Source ID'         : sourceID,
      'Collection ID'     : collectionID,
      'User ID'           : helpers.currentUserID(),
      'Is Own Collection' : helpers.isCurrentUser(collectionUserID)});
  },

  // User initiates the product ownership process
  //
  ownInitiated: function(source,sourceID,productID) {
    mpq.track('Own Initiated', {
      'Source'          : source,
      'Source ID'       : sourceID,
      'Product ID'      : productID,
      'User ID'         : helpers.currentUserID()});
  },

  // User cancels the product ownership process
  //
  ownCancelled: function(source,sourceID,productID) {
    mpq.track('Own Cancelled', {
      'Source'          : source,
      'Source ID'       : sourceID,
      'Product ID'      : productID,
      'User ID'         : helpers.currentUserID()});
  },

  // User owns a product
  //
  ownCreated: function(source,sourceID,productID) {
    mpq.track('Own Created', {
      'Source'          : source,
      'Source ID'       : sourceID,
      'Product ID'      : productID,
      'User ID'         : helpers.currentUserID()});
  },

  // User wants a product
  //
  wantCreated: function(source,sourceID,productID) {
    mpq.track('Want Created', {
      'Source'          : source,
      'Source ID'       : sourceID,
      'Product ID'      : productID,
      'User ID'         : helpers.currentUserID()});
  },

  // User opts in to write a review during creation
  //
  endorsementCreationSelected: function(mode) {
    mpq.track('Endorsement Creation Selected',{'Mode':mode});
  },

  // User start editing endorsement
  //
  endorsementEditingSelected: function(source) {
    mpq.track('Endorsement Editing Selected',{'source':source});
  },

  // User cancelled editing endorsement
  //
  endorsementEditingCancelled: function(source) {
    mpq.track('Endorsement Editing Cancelled',{'source':source});
  },

  // User completed editing endorsement
  //
  endorsementEditingCompleted: function(source) {
    mpq.track('Endorsement Editing Completed',{'source':source});
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
  inviteCompleted: function(count) {
    mpq.track("Invite Completed", {'count':count});
  },

  // User visits the site from an email
  //
  emailClicked: function(source) {
    mpq.track("Email Clicked", {
      'Source'  : source,
      'User ID' : helpers.currentUserID()});
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
  productSearched: function(query,mode) {
    mpq.track("Searched a product", {'query':query,'Mode':mode});
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
          'User ID'    : helpers.currentUserID()});
  },

  // User updates a product
  //
  productUpdated: function(productID) {
    mpq.track("Product Updated",{
          'Product ID' : productID,
          'User ID'    : helpers.currentUserID()});
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

  // Product's on a user's profile are filtered
  //
  userProfileFiltered: function(category,isCurrentUser,id) {
    mpq.track('User Profile Filtered',{
          "Category"         : category,
          "Is Own Profile"   : isCurrentUser,
          "id"               : id});
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

  // A type and category of a user's products are 
  // explictly viewed
  //
  userProductsView: function(type,category,userID) {
    mpq.track(
      'User ' + type.capitalize() + ' View',{
        'Category'        : category,
        'Is Own Profile'  : helpers.isCurrentUser(userID),
        'id'              : userID});
  },

  // A user's followers are viewed
  //
  userFollowersView: function(userID) {
    mpq.track(
      'User Followers View',{
        'Is Own Profile'  : helpers.isCurrentUser(userID),
        'id'              : userID});
  },

  // A user's ifollowers are viewed
  //
  userIFollowersView: function(userID) {
    mpq.track(
      'User IFollowers View',{
        'Is Own Profile'  : helpers.isCurrentUser(userID),
        'id'              : userID});
  },

  // A user's collections are viewed
  //
  userCollectionsView: function(userID) {
    mpq.track(
      'User Collections View',{
        'Is Own Profile'  : helpers.isCurrentUser(userID),
        'id'              : userID});
  },

  // User views the settings page
  //
  settingsView: function(source) {
    mpq.track('Settings View',{'source' : source});
  },

  // A collection is viewed
  //
  collectionView: function(source) {
    mpq.track(
      'Collection View',{
        'source' : source});
  },

  // Product's on a store's profile are filtered
  //
  storeProfileFiltered: function(category,id) {
    mpq.track('Store Profile Filtered',{
          "Category"         : category,
          "id"               : id});
  },

  // A store's products in a category are explicitly viewed
  //
  storeProductsView: function(category,storeID) {
    mpq.track('Store Products View',{
      'Category'  : category,
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

  // Page view on the collections new page
  //
  collectionNewView: function(source) {
     mpq.track(
      'Collection New View',{'source' : source});
  },

  // Page view on the collections edit page
  //
  collectionEditView: function(source) {
     mpq.track(
      'Collection Edit View',{'source' : source});
  },

  // User opts in to write a title while creating a collection
  //
  collectionTitleInitiated: function() {
    mpq.track('Collection Title Initiated');
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
  productNewView: function(category_id,category_name,source) {
    mpq.track("Creation Template Opened", 
      {
      'id'      : category_id,
      'name'    : category_name,
      'source'  : source
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
      'User ID'     : helpers.currentUserID(),
      'Source'      : source
      });
  }

});

