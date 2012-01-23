// Partial to load and display top shoppers at a store 
//
Denwen.Partials.Users.TopShoppers = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.store  = this.options.store;
    this.users  = new Denwen.Collections.Users();

    this.get();
  },

  // Fetches the top shoppers 
  //
  get: function() {
    var self    = this;

    this.users.fetch({
            data:     {store_id: this.store.get('id'), filter: 'top_shoppers'},
            success:  function(collection){self.render();},
            error:    function(collection,errors){}
            });
  },

  // Render the users collection
  //
  render: function() {
    if(this.users.isEmpty())
      $(this.el).hide();

    $(this.el).html(
      Denwen.JST['users/top_shoppers']({
        users         : this.users}));
  }

});
