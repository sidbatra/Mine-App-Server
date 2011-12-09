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
    var shelves     = new Denwen.Collections.Shelves();

    this.products.each(function(product){
      var category_id = product.get('category_id');
      var shelf = shelves.get(category_id);

      if(shelf == undefined) {
        shelf = new Denwen.Models.Shelf({id:category_id});
        shelves.add(shelf);
      }

      shelf.addProduct(product);
    });


    this.el.html('');

    shelves.sort();

    shelves.each(function(shelf) {
      self.el.prepend(
         Denwen.JST['products/shelf']({shelf : shelf}));
    });

    Categories.each(function(category){
      var category_id = category.get('id');

      if(shelves.get(category_id) == undefined) {
        var shelf = new Denwen.Models.Shelf({id:category_id});
        self.el.append(
          Denwen.JST['products/shelf']({shelf: shelf}));
      }
    });

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
