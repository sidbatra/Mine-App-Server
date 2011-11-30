// Partial to load and display user's facebook friends 
//
Denwen.Partials.Invites.FBFriends = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.accessToken = this.options.access_token;
    this.get();
  },

  // Fetches the facebook friends 
  //
  get: function() {
    var self    = this;
    this.users  = new Denwen.Collections.FBFriends(null,
                                            {access_token:this.accessToken});

    this.users.fetch({
            success:  function(collection){self.render();},
            error:    function(collection,errors){}
            });
  },

  // Render the users collection
  //
  render: function() {
    console.log("in render");
  }

});
