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
  
  // Track the page the user landed on
  //
  userLandsOn: function(page) {
    mpq.register_once({'landed_on' : page}); 
  },

  // User signs in
  //
  userLogin: function() {
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

  // User starts to type a comment
  //
  commentSelected: function() {
    mpq.track("Comment Selected");
  },

  // User creates a comment
  //
  commentCreated: function() {
    mpq.track("Comment Created");
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

  // User likes a product
  //
  likeCreated: function(source,sourceID,productID,productUserID) {
    mpq.track('Like Created', {
      'Source'          : source,
      'Source ID'       : sourceID,
      'Product ID'      : productID,
      'User ID'         : helpers.currentUserID(),
      'Is Own Product'  : helpers.isCurrentUser(productUserID)});
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
  endorsementCreationSelected: function() {
    mpq.track('Endorsement Creation Selected');
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
  },

  // User searches a product
  //
  productSearched: function(query) {
    mpq.track("Searched a product", {'query':query});
  },

  // Fired when an image selected by the user is broken
  //
  productImageBroken: function() {
    mpq.track("Product Image Broken");
  },

  // User cancels product search
  //
  productSearchCancelled: function() {
    mpq.track("Product Cancelled");
  },

  // User selects a product
  //
  productSearchCompleted: function() {
    mpq.track("Product Selected");
  },

  // Validation exception 
  //
  productException: function(type) {
    mpq.track("Product Exception",{'type':type});
  },

  // User creates a product
  //
  productCreated: function() {
    mpq.track("Item Created");
  },

  // User deletes a product
  //
  productDeleted: function() {
    mpq.track("Item Deleted");
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

  // Product's on a store's profile are filtered
  //
  storeProfileFiltered: function(category,id) {
    mpq.track('Store Profile Filtered',{
          "Category"         : category,
          "id"               : id});
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

  // User opens new products page
  //
  productNewView: function(category_id,category_name,source) {
    mpq.track("Creation Template Opened", 
      {
      'id'      : category_id,
      'name'    : category_name,
      'source'  : source
      });
  }

});
