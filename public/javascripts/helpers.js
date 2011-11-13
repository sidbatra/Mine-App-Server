// Url helper helps create routes for use in javascript templates
//
Denwen.Helpers = Backbone.Model.extend({

  //Constructor logic
  //
  initialize: function() {
    this.assetHost = $('meta[name=asset_host]').attr('content');
    this.current_user_id = $('meta[name=current_user_id]').attr('content');
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

  // Based on the rails helper image_path. The name of the
  // image is converted to its path in the image folder
  // taking into account the current assetHost
  //
  imagePath: function(imgName) {
    return this.assetHost + '/images/' + imgName;
  },

  // Test if the current user's id is equal to the given id
  //
  isCurrentUser: function(userID) {
    return this.current_user_id == userID;
  },

  // Empty div blocker used throughout the app
  //
  blocker: function() {
    return "<div id='blocker'></div>";
  },

  // Message displaying people the user is following
  //
  following_message: function(userID,ifollowersCount) {
    var message;

    if(ifollowersCount)
      message = this.isCurrentUser(userID) ? 
                  "People you're following" : 
                  "TODO is following";
    else
      message = this.isCurrentUser(userID) ? 
                  "People you're following" : 
                  "TODO isn't following anyone yet.";
    
    return message;
  }

});
