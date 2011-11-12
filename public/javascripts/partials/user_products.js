// Partial to load and display products for a user.
// Also handles filters on the products via a Router
//
Denwen.Partials.UserProducts = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.products = new Denwen.Collections.Products();
    this.products.fetch({
      data    : {filter: 'user',user_id: this.options.user_id},
      success : function() { self.render(); },
      error   : function() {}
    });
  },

  // Render the products collection
  //
  render: function() {
    var self = this;

    this.products.each(function(product){
      new Denwen.Partials.Product({el:self.el,model:product});
    });
  }

});
