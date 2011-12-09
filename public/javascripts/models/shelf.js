// Shelf model combined a set of products and a category id
//
Denwen.Models.Shelf = Backbone.Model.extend({

  // Constructor logic
  //
  initialize: function() {
    this.set({
      products: new Denwen.Collections.Products(),
      category: Categories.get(this.get('id'))});
  },

  // Add a product to the products collection
  //
  addProduct: function(product) {
    this.get('products').add(product);
  }

});
