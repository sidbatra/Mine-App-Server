// User's iFollowers 
//
Denwen.UserIfollowersView = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.id = this.options.id;
  },

  // Called when the iFollowers are successfully fetched 
  //
  fetched: function(users) {
   console.log(users.at(0)); 
  },

  // Fetches the iFollowers 
  //
  get: function() {
    var self  = this;
    var users = new Denwen.Users();

    users.fetch({
            data:     {id: this.id},
            success:  function(collection){self.fetched(collection)},
            error:    function(collection,errors){}
            });
  }
});
