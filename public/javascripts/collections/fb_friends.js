// Collection of user's facebook friends 
//
Denwen.Collections.FBFriends = Backbone.Collection.extend({

  // Model name
  //
  model: Denwen.Models.FBFriend,

  // Constructor logic
  //
  initialize: function(models,options) {
    this.accessToken = options['access_token'];
  },

  // Create url to the facebook graph api for fetching
  // user's facebook friends based on the access token
  //
  url: function() {
    var url = 
            "https://graph.facebook.com/me/friends?access_token=" + 
            this.accessToken;  

    console.log(url);

    return url;
  }

});
