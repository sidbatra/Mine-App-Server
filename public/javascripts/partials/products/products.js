// Partial to load and display products for an owner.
//
Denwen.Partials.Products.Products = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.ownerID    = this.options.owner_id;
    this.filter     = this.options.filter;
    this.jst        = this.options.jst;
    this.products   = new Denwen.Collections.Products();
  },

  // Render the products collection
  //
  render: function() {
    this.el.html('');
    this.el.prepend(
      Denwen.JST[this.jst]({
        products  : this.products,
        ownerID   : this.ownerID}));
  },

  // Fetch products filtered by the given category
  //
  fetch: function(category) {
    var self  = this;
    var data  = {filter: this.filter,owner_id: this.ownerID};

    if(category != undefined && category.length) 
      data['category']  = category;

    this.products.fetch({
      data    : data,
      success : function() { self.render(); },
      error   : function() {}
    });
  }

});
