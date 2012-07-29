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
  SuggestionClicked         : "suggestionClicked",
  SuggestionFinished        : "suggestionFinished",
  FBTokenDead               : "fbTokenDead"
};
