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

  // Page view on user profile
  //
  userProfileView: function(source,category) {
     mpq.track(
      'User Profile View',
      {
      'source'    : source,
      'category'  : category
      });
  },

  // Page view on product profile
  //
  productProfileView: function(source) {
     mpq.track(
      'Product Profile View',
      {'source'  : source});
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
