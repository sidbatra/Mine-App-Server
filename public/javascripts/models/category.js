// Category model represents a product category
//
Denwen.Models.Category = Backbone.Model.extend({

  // Constructor logic
  //
  initialize: function(){
  },

  // Indiciates whether the category is a primary one
  //
  isPrimary: function() {
    var handle = this.get('handle');
    return handle != 'decor' && handle != 'anything';
  }

});
