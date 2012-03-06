// Collection of Style models
//
Denwen.Collections.Styles = Backbone.Collection.extend({

  // Route on the app server
  //
  url: '/styles',

  // Base model
  //
  model: Denwen.Models.Style,
  
  // Constructor logic
  //
  initialize: function() {
  }

});
