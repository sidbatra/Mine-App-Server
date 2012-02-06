// Collection of Category models
//
Denwen.Collections.Categories = Backbone.Collection.extend({

  // Base model
  //
  model: Denwen.Models.Category,

  // Constructor logic
  //
  initialize: function() {
  },

  // Comparator function for sorting on the basis
  // of weight of the category
  //
  comparator: function(category) {
    return -category.get('weight');
  }

});
