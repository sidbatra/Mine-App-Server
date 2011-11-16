// Partial to load and display star users 
//
Denwen.Partials.Users.Stars = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.users  = new Denwen.Collections.Users();
    this.get();
  },

  // Fetches the star users 
  //
  get: function() {
    var self    = this;

    this.users.fetch({
            data:     {filter: 'stars'},
            success:  function(collection){self.render();},
            error:    function(collection,errors){}
            });
  },

  // Render the users collection
  //
  render: function() {
    $(this.el).html(
      Denwen.JST['users/stars']({
        users : this.users}));
  }

});
