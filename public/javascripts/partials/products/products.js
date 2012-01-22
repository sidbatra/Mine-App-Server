// Partial to load and display products along with category filters.
//
Denwen.Partials.Products.Products = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.ownerID    = this.options.owner_id;
    this.filter     = this.options.filter;
    this.type       = this.options.type;
    this.products   = new Denwen.Collections.Products();
  },

  // Render the products collection
  //
  render: function() {

    this.el.html('');
    this.el.prepend(
      Denwen.JST['products/products']({
        products  : this.products,
        ownerID   : this.ownerID,
        src       : this.filter,
        type      : this.type}));

    this.products.each(function(product){
      new Denwen.Partials.Products.Product({
            model     : product,
            source    : self.filter,
            sourceID  : self.ownerID});
    });
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
