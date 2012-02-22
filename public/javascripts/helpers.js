// Url helper helps create routes for use in javascript templates
//
Denwen.Helpers = Backbone.Model.extend({

  //Constructor logic
  //
  initialize: function() {
    this.assetHost        = $('meta[name=asset_host]').attr('content');
    this.current_user_id  = $('meta[name=current_user_id]').attr('content');
    this.isOnboarding     = $('meta[name=is_onboarding]').attr('content') == 'true'; 
    this.version          = $('meta[name=version]').attr('content'); 
  },

  // Truncate str to length using omissions
  // as truncating characters
  //
  truncate: function(str,length,omission) {
    return str.length <= length ? 
            str : 
            str.slice(0,Math.max(length-omission.length,0)) + 
                omission;
  },

  // Inspired from rails helpers this helper converts relative
  // paths of assets to full qualified paths using the available
  // assetHost. This defaults to local folders during development
  // and CDN paths in production
  //
  assetPath: function(folder,assetName) {
    return this.assetHost + '/' + folder + '/' + assetName;
  },

  // JS helper inspired from rails image_path
  //
  imagePath: function(imgName) {
    return this.assetPath('images',imgName);
  },

  // SWF version of rails image_path
  //
  swfPath: function(swfName) {
    return this.assetPath('swfs',swfName);
  },

  // Tests if a user is currently logged in
  //
  isLoggedIn: function() {
    return this.current_user_id != 0;
  },

  // Returns the current user id
  //
  currentUserID: function() {
    return this.current_user_id;
  },

  // Test if the current user's id is equal to the given id
  //
  isCurrentUser: function(userID) {
    return this.current_user_id && this.current_user_id == userID;
  },

  // Get the ordinal from an integer
  //
  ordinal: function(n) {
    var s=["th","st","nd","rd"],
       v=n%100;
    return n+(s[(v-20)%10]||s[v]||s[0]); 
  },

  // Currency string for price
  //
  displayCurrency: function(price) {
    return '$' + price.toFixed(2).replace(/\.00$/,'');
  },

  // Empty div blocker used throughout the app
  //
  blocker: function() {
    return "<div id='blocker'></div>";
  },

  // Generate path for creating a product in a category
  //
  newProductPath: function(category,src) {
    return '/products/new?category=' + category + '&src=' + src;
  },

  // Generate path for inviting users
  //
  newInvitePath: function(src) {
    return '/invites/new?src=' + src;
  }

});
