// Partial to load and display products for a user.
// Also handles filters on the products via a Router
//
Denwen.Partials.UserProducts = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.userID   = this.options.user_id;
    this.products = new Denwen.Collections.Products();

    this.products.fetch({
      data    : {filter: 'user',user_id: this.userID},
      success : function() { self.render(); },
      error   : function() {}
    });
  },

  // Render the products collection
  //
  render: function() {
    this.el.prepend(
      Denwen.JST['products/user_products']({
        products  : this.products,
        userID    : this.userID}));
  }

});
