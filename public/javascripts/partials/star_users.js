// Partial to load and display star users 
//
Denwen.Partials.StarUsers = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.starUsersEl  = '#star_users';
    this.get();
  },

  // Fetches the star users 
  //
  get: function() {
    var self    = this;
    this.users  = new Denwen.Collections.Users();

    this.users.fetch({
            data:     {filter: 'stars'},
            success:  function(collection){self.render();},
            error:    function(collection,errors){}
            });
  },

  // Render the users collection
  //
  render: function() {
    var self = this;

    this.users.each(function(user){
      new Denwen.Partials.User({el:$(self.starUsersEl),model:user});
    });
  }

});
