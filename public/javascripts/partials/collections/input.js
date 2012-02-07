// Partial for managing part of the collection
// creation and editing form
//
Denwen.Partials.Collections.Input = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
    "click #collection_title_initiate"   : "titleInitiated"
  },

  // Constructor logic
  //
  initialize: function() {
    var self              = this;

    this.currentUserID    = this.options.currentUserID;

    this.productsEl       = '#items';
    this.productIdsEl     = '#collection_product_ids';
    this.titleEl          = '#collection_name';
    this.titleInitiateEl  = '#collection_title_initiate';

    this.posting          = false;

    this.productPickers = new Array(); 
    this.productsPicked = new Array(); 

    this.el.submit(function(){return self.post();});

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
      analytics.collectionException();
    }
    else {
      $(this.productIdsEl).val(this.productsPicked.join(","));
    }

    this.posting = valid;

    return valid;
  },

  // User initiate creation of the title 
  //
  titleInitiated: function() {
    $(this.titleInitiateEl).hide();

    $(this.titleEl).show();
    $(this.titleEl).focus();

    analytics.collectionTitleInitiated();
  }

});
