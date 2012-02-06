// Collection of Shopping models
//
Denwen.Collections.Shoppings = Backbone.Collection.extend({

  // Base model
  //
  model: Denwen.Models.Shopping,

  // Constructor logic
  //
  initialize: function() {
  },

  // Comparator function for sorting on the basis
  // of the products count
  //
  comparator: function(shopping) {
    return -shopping.get('products_count');
  }

});
