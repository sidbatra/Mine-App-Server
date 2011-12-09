// Partial to load and display products for a user
//
Denwen.Partials.Users.Shelves = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.ownerID    = this.options.owner_id;
    this.products   = new Denwen.Collections.Products();

    this.fetch();
  },

  // Render the products collection
  //
  render: function() {
    var self        = this;
    var categories  = new Array();
    var sortMethod  = function(a,b) { return b.length > a.length;};

    this.products.each(function(product){
      var category_id = product.get('category_id');

      if(categories[category_id] == undefined) {
        categories[category_id] = [product];
      }
      else {
        categories[category_id].push(product);
      }
    });


    this.el.html('');

    
    categories = categories.sort(sortMethod);

    for(i in categories) {
      var subset = new Denwen.Collections.Products(categories[i]);

      this.el.append(
        Denwen.JST['products/shelf']({
          products  : subset}));
    }
      

    this.products.each(function(product){
      new Denwen.Partials.Products.Product({
            model     : product,
            source    : 'user',
            sourceID  : self.ownerID});
    });
  },

  // Fetch products 
  //
  fetch: function() {
    var self  = this;
    var data  = {filter: 'user',owner_id: this.ownerID};

    this.products.fetch({
      data    : data,
      success : function() { self.render(); },
      error   : function() {}
    });
  }

});
