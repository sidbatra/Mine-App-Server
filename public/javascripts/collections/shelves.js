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
  // of shelf with the most recent product
  //
  comparator: function(shelf) {
    return shelf.get('products').isEmpty() ? 
                  0 : 
                  shelf.get('products').first().get('id');
  }

});
