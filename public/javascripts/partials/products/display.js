// Partial for handling rendering and interactions of a product display.
//
Denwen.Partials.Products.Display = Backbone.View.extend({


  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.render();
  },

  // Render the contents of the model.
  //
  render: function() {
    this.el.append(
      Denwen.JST['products/display'](
        {product: this.model}));
  }

});
