// Collection of Suggestion models 
//
Denwen.Collections.Suggestions = Backbone.Collection.extend({

  // Model name
  //
  model: Denwen.Models.Suggestion,

  // Route on the app server 
  //
  url: '/suggestions',

  // Constructor logic
  //
  initialize: function() {
  }

});
