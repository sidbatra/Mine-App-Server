// Purchase model represents a purchase that a
// user owns
//
Denwen.Models.Purchase = Backbone.Model.extend({

  // Route on the app server
  //
  urlRoot: '/purchases',

  // Constructor logic
  //
  initialize: function(){
    this.associate('store',Denwen.Models.Store);
    this.associate('user',Denwen.Models.User);
    this.associate('likes',Denwen.Collections.Likes);
    this.associate('comments',Denwen.Collections.Comments);

    if(this.get('bought_at'))
      this.creationTimestamp = this.get('bought_at').toDate().getTime() * 0.001;
  },

  displayTimestamp: function() {
    var createdAt = this.get('bought_at').toDate();
    var msElapsed = new Date() - createdAt;
    var timestamp = "";

    if(msElapsed < 86400000)
      timestamp = "Today";
    else if(msElapsed < 172800000)
      timestamp = "Yesterday";
    else
      timestamp = createdAt.getDate() + " " + Denwen.H.monthForDate(createdAt);

    return timestamp;
  },

  // Base path to the purchase with any additional args
  //
  basePath: function() {
    return '/' + this.get('user').get('handle') + '/p/' + 
      this.get('handle');
  },

  // Path to the purchase with the originating source
  //
  path: function(src) {
    return this.basePath() + '?src=' + src;
  },

  // Absolute URL to the purchase with originating src
  //
  absoluteURL: function(src) {
    return "http://" + window.location.hostname + this.path(src);
  },

  // Path to the edit view of the purchase with an originating source
  //
  editPath: function(src) {
    return this.basePath() + '/edit?src=' + src;
  },

  // Unique key to identify the unique combination of the
  // model name and the id
  //
  uniqueKey: function() {
    return 'purchase_' + this.get('id');
  },
  
  // Returns if the purchase is currently in the process of being 
  // shared to facebook
  //
  hasSharingUnderway: function() {
    return this.get('fb_object_id') == Denwen.FBSharing.Underway;
  },

  // Returns if the purchase is native to the mine network 
  //
  isNative: function() {
    return this.get('fb_object_id') == null;
  },

  sharingMessage: function() {
    var message = "";

    if(Denwen.H.isCurrentUser(this.get('user').get('id')))
      message = "Bought my ";
    else
      message = this.get('user').get('first_name') + " bought " + 
                  this.get('user').pronoun() + " ";
    
    message = message + this.get('title');

    if(this.get('store'))
      message = message + " from " + this.get('store').get('name');

    if(this.get('endorsement'))
      message = message + ". " + this.get('endorsement');

    return message;
  }

});


