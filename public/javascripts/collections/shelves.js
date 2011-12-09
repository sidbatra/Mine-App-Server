// Collection of Shelf models
//
Denwen.Collections.Shelves = Backbone.Collection.extend({

  // Model name
  //
  model: Denwen.Models.Shelf,

  // Constructor logic
  //
  initialize: function() {
  },

  // Comparator function for sorting on the basis
  // of total number of products
  //
  comparator: function(shelf) {
    return shelf.get('products').length;
  }

});
