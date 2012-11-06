// Url helper helps create routes for use in javascript templates
//
Denwen.Helpers = Backbone.Model.extend({

  //Constructor logic
  //
  initialize: function() {
    this.currentUser        = undefined;
    this.assetHost          = $('meta[name=asset_host]').attr('content');
    this.current_user_id    = $('meta[name=current_user_id]').attr('content');
    this.currentUserGender  = $('meta[name=current_user_gender]').attr('content');
    this.isOnboarding       = $('meta[name=is_onboarding]').attr('content') == 'true'; 
    this.version            = $('meta[name=version]').attr('content'); 
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

  // If the current user is male or not
  //
  // Returns. Boolean. true if current user is male
  //
  isCurrentUserMale: function() {
    var firstChar = this.currentUserGender[0];
    return firstChar == 'm' && firstChar != 'u';
  },

  // If the current user is female or not
  //
  // Returns. Boolean. true if current user is female
  //
  isCurrentUserFemale: function() {
    var firstChar = this.currentUserGender[0];
    return firstChar == 'f' && firstChar != 'u';
  },

  // Get the ordinal from an integer
  //
  ordinal: function(n) {
    var s=["th","st","nd","rd"],
       v=n%100;
    return n+(s[(v-20)%10]||s[v]||s[0]); 
  },

  // Empty div blocker used throughout the app
  //
  blocker: function() {
    return "<div id='blocker'></div>";
  },

  // Generate path for inviting users
  //
  newInvitePath: function(src) {
    return '/invite?src=' + src;
  },

  // Generate facebook image url for the user
  // with the given id 
  //
  fbImageUrl: function(id) {
    return 'https://graph.facebook.com/' + id + '/picture?type=square';
  },

  // Returns an abbreviated month name for the month of the date object given.
  //
  monthForDate: function(dateObject) {
    this.monthNames = this.monthNames || ["Jan", "Feb", "Mar", "Apr", "May", 
                                          "Jun", "Jul", "Aug", "Sep", "Oct", 
                                          "Nov", "Dec"];
    return this.monthNames[dateObject.getMonth()];
  },

  // Display a popup to the given URL in the center
  // of the screen.
  //
  popup: function(url,width,height) {
    var x = (screen.width-width) / 2;
    var y = (screen.height-height) / 2;

    return window.open(url,'','left='+x+', top='+y+ ', width=' +width+ ', height=' +height);
  }

});
