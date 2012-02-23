// Partial to load and display user's stores
//
Denwen.Partials.Users.Stores = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.user   = this.options.user;
    this.stores = new Denwen.Collections.Stores();

    this.get();
  },

  // Fetch user's stores from the app server
  //
  get: function() {
    var self = this;

    this.stores.fetch({
          data      : {filter: 'for_user', user_id: this.user.get('id')},
          success   : function(collection){self.render();},
          error     : function(collection,errors){}
    });
  },

  // Render the top stores
  //
  render: function() {
    if(this.stores.isEmpty() && !helpers.isCurrentUser(this.user.get('id'))) {
      $(this.el).hide();
      return;
    }

    $(this.el).html(
      Denwen.JST['users/stores']({
        stores  : this.stores,
        user    : this.user}));
  }

});
