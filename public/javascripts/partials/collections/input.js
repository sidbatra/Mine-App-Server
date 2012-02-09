// Partial for managing part of the collection
// creation and editing form
//
Denwen.Partials.Collections.Input = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self              = this;

    this.currentUserID    = this.options.currentUserID;
    this.productIDs       = this.options.productIDs;

    this.productsEl       = '#items';
    this.productIdsEl     = '#collection_product_ids';
    this.titleEl          = '#collection_name';
    this.titleTextEl      = '#name_text';

    this.posting          = false;

    this.productPickers = new Array(); 
    this.productsPicked = new Array(); 

    this.el.submit(function(){return self.post();});

    restrictFieldSize($(this.titleEl),254,'charsremain');

    this.get();
  },

  // Fetches the products 
  //
  get: function() {
    var self        = this;
    this.products   = new Denwen.Collections.Products();

    this.products.fetch({
          data:     {owner_id: this.currentUserID, filter: 'user'},
          success:  function(collection){self.fetched();},
          error:    function(collection,errors){}
          });
  },

  // Fired when the products json has been fetched from
  // the server
  //
  fetched: function(){
    var self = this;

    $(this.productsEl).html('');

    this.products.each(function(product){
      var productPicker = new Denwen.Partials.Products.Picker({
                                        model : product,
                                        el    : $(self.productsEl)
                                        });

      productPicker.bind('addToProductsPicked',self.addToProductsPicked,self);
      productPicker.bind('removeFromProductsPicked',
                          self.removeFromProductsPicked,self);

      self.productPickers.push(productPicker);

      if(_.include(self.productIDs,product.get('id').toString()))
        productPicker.clicked();

    });
  },

  // Fired when a product is turned on 
  //
  addToProductsPicked: function(productID) {
    this.productsPicked.push(productID);
  },

  // Fired when a product is turned off
  //
  removeFromProductsPicked: function(productID) {
    this.productsPicked = _.without(this.productsPicked,productID);
  },

  // Form submitted callback
  //
  post: function() {

    if(this.posting)
      return false;

    this.posting  = true;
    var valid     = true;
    
    if(this.productsPicked.length < 1) {
      valid = false;
      alert("Please add at least one item.");
      analytics.collectionException('No Products');
    }
    else {
      $(this.productIdsEl).val(this.productsPicked.join(","));
    }

    if($(this.titleEl).val().length < 1) {
      valid = false;

      $(this.titleEl).addClass('incomplete');
      $(this.titleTextEl).addClass('incomplete');
      analytics.collectionException('No Name');
    }
    else {
      $(this.titleEl).removeClass('incomplete');
      $(this.titleTextEl).removeClass('incomplete');
    }

    this.posting = valid;

    return valid;
  }

});
