// Partial to load and display products along with category filters.
//
Denwen.Partials.Products.Products = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.ownerID    = this.options.owner_id;
    this.ownerName  = this.options.owner_name;
    this.filter     = this.options.filter;
    this.type       = this.options.type;
    this.fragment   = this.options.fragment;

    this.products   = new Denwen.Collections.Products();
  },

  // Render the products collection
  //
  render: function() {
    var self = this;
    
    this.products.reset();
    
    this.el.html('');
    this.el.prepend(
      Denwen.JST['products/products']({
        products        : this.products,
        ownerID         : this.ownerID,
        ownerName       : this.ownerName,
        src             : this.filter,
        type            : this.type,
        fragment        : this.fragment}));

    this.products.each(function(product){
      new Denwen.Partials.Products.Product({
            model     : product,
            source    : self.filter,
            sourceID  : self.ownerID});
    });

    this.trigger(Denwen.Callback.ProductsRendered);
  },

  // Fetch products filtered by the given category
  //
  fetch: function() {
    var self  = this;
    var data  = {filter: this.filter,owner_id: this.ownerID};

    this.products.fetch({
      data    : data,
      success : function() { 
                  self.trigger(Denwen.Callback.ProductsLoaded); 
                  self.render();},
      error   : function() {}
    });
  }

});
