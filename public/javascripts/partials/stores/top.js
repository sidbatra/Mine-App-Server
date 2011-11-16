// Partial to load and display top stores
//
Denwen.Partials.Stores.Top = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.stores = new Denwen.Collections.Stores();
    this.get();
  },

  // Fetch top stores from the app server
  //
  get: function() {
    var self = this;

    this.stores.fetch({
          data      : {filter: 'top'},
          success   : function(collection){self.render();},
          error     : function(collection,errors){}
    });
  },

  // Render the top stores
  //
  render: function() {
    $(this.el).html(
      Denwen.JST['stores/top']({
        stores : this.stores}));
  }


});
