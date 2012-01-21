// Partial to load and display top products at a store.
//
Denwen.Partials.Products.TopProducts = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.ownerID    = this.options.owner_id;
    this.products   = new Denwen.Collections.Products();

    this.fetch();
  },

  // Fetch products 
  //
  fetch: function() {
    var self  = this;

    this.products.fetch({
      data    : {filter: 'top',owner_id: this.ownerID},
      success : function() { self.render(); },
      error   : function() {}
    });
  },

  // Render the products collection
  //
  render: function() {
    if(this.products.isEmpty())
      $(this.el).hide();

    this.el.html('');
    this.el.prepend(
      Denwen.JST['products/top_products']({
        products  : this.products,
        ownerID   : this.ownerID}));
  }

});
