// Shopping model represents a user shops at a store
//
Denwen.Models.Shopping = Backbone.Model.extend({

  // Constructor logic
  //
  initialize: function(){
    this.associate('store',Denwen.Models.Store);
  }

});
