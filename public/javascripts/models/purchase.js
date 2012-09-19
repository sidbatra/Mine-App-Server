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

    if(this.get('created_at'))
      this.creationTimestamp = this.get('created_at').toDate().getTime() * 0.001;
  },

  displayTimestamp: function() {
    var createdAt = this.get('created_at').toDate();
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
  }

});


