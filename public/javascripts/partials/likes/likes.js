// Partial to load and display facebook likes 
// for a single product 
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
    this.likes.each(function(like){
      new Denwen.Partials.Likes.Like({
            like  : like,
            el    : '#likes_' + like.get('product_id')});
    });
  }

});
