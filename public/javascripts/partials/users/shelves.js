// Partial to load and display products for a user
//
Denwen.Partials.Users.Shelves = Backbone.View.extend({

  //Setup event handlers
  //
  events: {
    "click .next_arrow" : "scrollRight", 
    "click .prev"       : "scrollLeft" 
  },

  // Constructor logic
  //
  initialize: function() {
    this.ownerID    = this.options.owner_id;
    this.products   = new Denwen.Collections.Products();
    this.onProducts = new Denwen.Collections.Products();
    this.shelves    = new Denwen.Collections.Shelves();

    this.shelfEl    = '.row';
    this.productsEl = '#products';

    this.productsLoaded   = false;
    this.onProductsLoaded = false;
    this.scrollingOffset  =  5;

    this.fetchOnProducts();
    this.fetch();
  },

  // Hooks up the scrolling plugin with custom options
  //
  hookUpScrolling: function() {
   $(this.shelfEl).scrollable({
                      items     : this.productsEl,
                      prev      : "",
                      next      : "",
                      keyboard  : false});
  },

  // Scrolls the shelf items right 
  //
  scrollRight: function(event) {
    $(event.target).parent().data("scrollable").move(this.scrollingOffset);
  },

  // Scrolls the shelf items left 
  //
  scrollLeft: function(event) {
    $(event.target).parent().data("scrollable").move(-this.scrollingOffset);
  },

  // Render the products collection
  //
  render: function() {
    var self = this;

    this.el.html('');

    this.shelves.each(function(shelf) {
      self.el.prepend(
         Denwen.JST['products/shelf']({
          shelf: shelf, 
          on: false, 
          user_id: self.ownerID}));
    });

    this.el.prepend(
      Denwen.JST['products/shelf']({
        shelf: this.topShelf, 
        on: true,
        user_id :this.ownerID}));

    this.products.each(function(product){
      new Denwen.Partials.Products.Product({
            model     : product,
            source    : 'user',
            sourceID  : self.ownerID});
    });

    this.hookUpScrolling();
  },

  // Fetch products 
  //
  fetch: function() {
    var self  = this;

    this.products.fetch({
      data    : {filter: 'user',owner_id: this.ownerID},
      success : function() { self.productsLoaded = true; self.assemble(); },
      error   : function() {}
    });
  },

  // Fetch on products 
  //
  fetchOnProducts: function() {
    var self  = this;

    this.onProducts.fetch({
      data    : {filter: 'collection',owner_id: this.ownerID},
      success : function() { self.onProductsLoaded = true; self.assemble(); },
      error   : function() {}
    });
  },

  // Assemble shelves from products before rendering
  //
  assemble: function() {
    if(!this.productsLoaded || !this.onProductsLoaded)
      return;

    var self = this;

    this.topShelf = new Denwen.Models.Shelf({id:1,products:this.onProducts});

    this.products.each(function(product){
      
      if(self.onProducts.get(product.get('id')) == undefined) {

        var category_id = product.get('category_id');
        var shelf       = self.shelves.get(category_id);

        if(shelf == undefined) {
          shelf = new Denwen.Models.Shelf({id:category_id});
          self.shelves.add(shelf);
        }

        shelf.addProduct(product);
      }
    });


    Categories.each(function(category){
      var category_id = category.get('id');

      if(self.shelves.get(category_id) == undefined)
        self.shelves.add(new Denwen.Models.Shelf({id:category_id}));
    });

    this.shelves.sort();

    this.render();
  }

});
