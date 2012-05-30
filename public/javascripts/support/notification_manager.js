// Notification Manager for scheduling notifications 
// throughout the JS codebase
//
Denwen.NotificationManager = Backbone.Model.extend({

  //Constructor logic
  //
  initialize: function() {
  }

});

// Define callbacks.
//
Denwen.NotificationManager.Callback= {
  CommentFetched            : "commentFetched",
  CommentCreated            : "commentCreated",
  DisableComments           : "disableComments",
  LikeFetched               : "likeFetched",
  LikeCreated               : "likeCreated",
  LikesFetched              : "likesFetched",
  DisableLikes              : "disableLikes"
};
