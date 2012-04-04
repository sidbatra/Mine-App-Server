// Partial to load, display and create facebook likes 
// for products
//
Denwen.Partials.Likes.Likes = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.likes = new Denwen.Collections.Likes();
  },

  // Fetch the likes for the given product ids
  //
  fetch: function(productIds) {
    var self = this;

    this.likes.fetch({
            data      : {product_ids : productIds},
            success   : function() { self.render(); },
            error     : function() {}
          });
  },

  // Render the likes collection
  //
  render: function() {
    console.log(this.likes);
  }

});
