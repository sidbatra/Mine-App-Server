// Shelf model combined a set of products and a category id
//
Denwen.Models.Shelf = Backbone.Model.extend({

  // Constructor logic
  //
  initialize: function() {
    this.set({category: Categories.get(this.get('id'))});

    if(!this.has('products'))
      this.set({products: new Denwen.Collections.Products()});
  },

  // Add a product to the products collection
  //
  addProduct: function(product) {
    this.get('products').add(product);
  }

});
