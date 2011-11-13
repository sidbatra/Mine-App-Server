// Partial to load and display products for a user.
// Also handles filters on the products via a Router
//
Denwen.Partials.UserProducts = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.userID   = this.options.user_id;
    this.products = new Denwen.Collections.Products();
  },

  // Render the products collection
  //
  render: function() {
    this.el.html('');
    this.el.prepend(
      Denwen.JST['products/user_products']({
        products  : this.products,
        userID    : this.userID}));
  },

  // Filter products based on the given category
  //
  filter: function(category) {
    this.fetch(category);
  },

  // Fetch products filtered by the given category
  //
  fetch: function(category) {
    var self  = this;
    var data  = {filter: 'user',user_id: this.userID};

    if(category != undefined && category.length) 
      data['category']  = category;

    this.products.fetch({
      data    : data,
      success : function() { self.render(); },
      error   : function() {}
    });
  }

});
