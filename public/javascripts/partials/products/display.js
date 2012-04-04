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
    var html = Denwen.JST['products/display']({product: this.model});

    if(this.model.get('fresh'))
      this.el.prepend(html);
    else
      this.el.append(html);
  }

});
