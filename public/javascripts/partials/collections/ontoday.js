// Partial to load and display a user's latest collection
//
Denwen.Partials.Collections.OnToday = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.userID     = this.options.userID;
  },

  // Fetch the user's latest collection
  //
  fetch: function() {
    var self = this;

    this.collection = new Denwen.Models.Collection();
    this.collection.fetch({
          data      : {filter: 'user_last',owner_id: self.userID},
          success   : function(collection){self.render();},
          error     : function(collection,errors){}
    });
  },

  // Render the top stores
  //
  render: function() {
    $(this.el).html(
      Denwen.JST['collections/ontoday']({
        collection : this.collection}));
  }


});
