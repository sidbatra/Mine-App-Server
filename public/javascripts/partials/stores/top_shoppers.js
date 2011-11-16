// Partial to load and display top shoppers for a store 
//
Denwen.Partials.Stores.TopShoppers = Backbone.View.extend({

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

  // Fetches the top shoppers 
  //
  get: function() {
    var self    = this;

    this.users.fetch({
            data:     {store_id: 454, filter: 'top_shoppers'},
            success:  function(collection){self.render();},
            error:    function(collection,errors){}
            });
  },

  // Render the users collection
  //
  render: function() {
    $(this.el).html(
      Denwen.JST['users/top_shoppers']({
        users : this.users}));
  }

});
