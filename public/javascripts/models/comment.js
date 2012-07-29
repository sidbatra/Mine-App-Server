// Comment model represents a facebook comment 
//
Denwen.Models.Comment = Backbone.Model.extend({

  // Route on the app server 
  //
  urlRoot: '/comments',

  // Constructor logic
  //
  initialize: function(){
    this.associate('user',Denwen.Models.User);
  }

});
