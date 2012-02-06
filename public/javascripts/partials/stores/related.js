// Partial to related stores for a particular store
//
Denwen.Partials.Stores.Related = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.store   = this.options.store;
    this.stores  = new Denwen.Collections.Stores();

    this.fetch();
  },

  // Fetch the relared stores
  //
  fetch: function() {
    var self = this;

    this.stores.fetch({
          data      : {filter: 'related', store_id: this.store.get('id')},
          success   : function(collection){self.render();},
          error     : function(collection,errors){}
    });
  },

  // Render the top stores
  //
  render: function() {
    var self = this;

    this.stores = new Denwen.Collections.Stores(
                        this.stores.reject(
                          function(store){
                            return store.get('id') == self.store.get('id')}));

    if(this.stores.isEmpty()) {
      $(this.el).hide();
      return;
    }

    $(this.el).html(
      Denwen.JST['stores/related']({
        stores  : this.stores}));
  }

});
