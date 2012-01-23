// Partial to load and display users in a box with detailed info
//
Denwen.Partials.Users.List = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.userID = this.options.userID;
    this.filter = this.options.filter;
    this.header = this.options.header;
    this.src    = this.options.src;

    this.users  = new Denwen.Collections.Users();
  },

  // Fetches the users
  //
  fetch: function() {
    var self    = this;

    this.users.fetch({
            data:     {id: this.userID, filter: this.filter},
            success:  function(collection){self.render();},
            error:    function(collection,errors){}
            });
  },

  // Render the users collection
  //
  render: function() {
    $(this.el).html(
      Denwen.JST['users/list']({
        users         : this.users, 
        header        : this.header,
        src           : this.src}));
  }

});

