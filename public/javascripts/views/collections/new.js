// View for creating new collections
//
Denwen.Views.Collections.New = Backbone.View.extend({
  
  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self            = this;

    this.source         = this.options.source;

    this.productsEl     = '#items';
    this.formEl         = '#new_collection';
    this.productIdsEl   = '#collection_product_ids';

    this.posting        = false;

    this.currentUser    = new Denwen.Models.User(this.options.currentUserJSON);
    this.productPickers = new Array(); 
    this.productsPicked = new Array(); 

    $(this.formEl).submit(function(){return self.post();});

    this.get();
    this.setAnalytics();
  },

  // Fetches the products 
  //
  get: function() {
    var self        = this;
    this.products   = new Denwen.Collections.Products();

    this.products.fetch({
          data:     {owner_id: this.currentUser.get('id'), filter: 'user'},
          success:  function(collection){self.fetched();},
          error:    function(collection,errors){}
          });
  },

  // Fired when the products json has been fetched from
  // the server
  //
  fetched: function(){
    var self = this;

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

    $(this.formEl).show();
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
      alert("Please add atleast one item.");
    }
    else {
      $(this.productIdsEl).val(this.productsPicked.join(","));
    }

    this.posting = valid;

    return valid;
  },

  // Fire tracking events
  //
  setAnalytics: function() {
    analytics.collectionNewView(this.source);
  }

});
