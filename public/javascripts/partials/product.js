// Render a single product
//
Denwen.Partials.Product = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.render();
  },

  // Render the product
  //
  render: function() {
    this.el.prepend(Denwen.JST['products/product']({product:this.model}));
  }
});
