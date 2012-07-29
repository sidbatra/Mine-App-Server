// Like model represents a facebook like 
//
Denwen.Models.Like = Backbone.Model.extend({

  // Route on the app server 
  //
  urlRoot: '/likes',

  // Constructor logic
  //
  initialize: function(){
    this.associate('user',Denwen.Models.User);
  }

});
