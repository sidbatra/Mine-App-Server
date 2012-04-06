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

    if(Denwen.H.isLoggedIn() && this.model.get('fb_object_id')) {
      new Denwen.Partials.Likes.New({product_id:this.model.get('id')});
      new Denwen.Partials.Comments.New({product_id:this.model.get('id')});
    }
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
