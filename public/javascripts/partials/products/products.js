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
    this.categories = new Denwen.Collections.Categories();
    this.category   = '';
  },

  // Render the products collection
  //
  render: function() {
    var self = this;

    if(this.category == 'all' || this.category == undefined) {
      this.categories = new Denwen.Collections.Categories();

      this.products.each(function(product){
        if(self.categories.get(product.get('category_id')) == undefined)
          self.categories.add(Categories.get(product.get('category_id')));
      });

      this.categories.sort();
    }
    
    this.el.html('');
    this.el.prepend(
      Denwen.JST['products/products']({
        products        : this.products,
        ownerID         : this.ownerID,
        ownerName       : this.ownerName,
        src             : this.filter,
        type            : this.type,
        fragment        : this.fragment,
        categories      : this.categories,
        currentCategory : this.category}));

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

    this.category = category;

    this.products.fetch({
      data    : data,
      success : function() { 
                  self.trigger('productsLoaded'); 
                  self.render();},
      error   : function() {}
    });
  }

});
