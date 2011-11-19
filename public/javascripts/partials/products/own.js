// Display the UI for claiming ownership of a product 
//
Denwen.Partials.Products.Own  = Backbone.View.extend({

  // Event listeners
  //
  events: {
    "click #create_own" : "create",
    "click #cancel_own" : "cancel"
  },

  // Constructor logic
  //
  initialize: function() {
    var self        = this;

    this.productID  = this.options.product_id;
    this.posting    = false;

    this.render();

    this.boxEl                = $('#own_box_' + this.productID);
    this.priceEl              = $('#product_price_' + this.productID);
    this.priceDollarEl        = $('#creation_dollar_' + this.productID);
    this.storeEl              = $('#product_store_name_' + this.productID);
    this.isGiftEl             = $('#product_is_gift_' + this.productID);
    //this.isGiftBoxEl          = $('#is_gift_box');
    this.isStoreUnknownEl     = $('#product_is_store_unknown_' + this.productID);
    //this.isStoreUnknownBoxEl  = $('#is_store_unknown_box');

    this.isGiftEl.change(function(){self.isGiftChanged();});
    this.isStoreUnknownEl.change(function(){self.isStoreUnknownChanged();});
  },

  // Display the UI for claiming ownership
  //
  render: function() {
    this.el.append(Denwen.JST['products/own']({id:this.productID}));
  },

  // Display the own box
  //
  display: function() {
    this.boxEl.show();
  },

  // Hide the own box
  //
  vanish: function() {
    this.boxEl.hide();
  },

  // Create ownership
  //
  create: function() {
    if(this.posting || !this.isValid())
      return false;

    this.posting = true;

    var params = {
                  is_gift:this.isGifted() ? '1' : '0',
                  is_store_unknown:this.isStoreUnknown() ? '1' : '0',
                  source_product_id:this.productID};

    if(!this.isGifted())
      params['price'] = this.priceEl.val();

    if(!this.isStoreUnknown())
      params['store_name'] = this.storeEl.val();


    var product = new Denwen.Models.Product(params); 
    product.save();

    this.vanish();
    this.trigger('ownCreated');

    return false;
  },

  // Cancel ownership creation
  //
  cancel: function() {
    if(this.posting)
      return false;

    this.vanish();
    this.trigger('ownCancelled');

    return false;
  },

  // Perform validation on the inputs
  //
  isValid: function() {
    var valid = true;

    if(!this.isGifted() && this.priceEl.val().length < 1) {
      valid = false;
      alert("Please enter the price of your item.");
      //analytics.productException('No Price',this.mode);
    }
    else if(!this.isGifted() && isNaN(this.priceEl.val())) {
      valid = false;
      alert("Please enter a valid price.");
      //analytics.productException('Invalid Price',this.mode);
    }
    else if(!this.isStoreUnknown() && this.storeEl.val().length < 1) {
      valid = false;
      alert("Please enter the store where you bought this item.");
      //analytics.productException('No Store',this.mode);
    }

    return valid;
  },

  // Returns the current state of the gifted check box
  //
  isGifted: function() {
    return this.isGiftEl.is(':checked');
  },

  // Fired when the user toggles the is gift check box
  //
  isGiftChanged: function() {

    if(this.isGifted()) {
      this.priceEl.val('');
      //$(this.priceEl).addClass('creation_input_inactive');
      this.priceEl.attr('disabled','disabled');
      //$(this.isGiftBoxEl).addClass('creation_checkbox_right_active');
      //$(this.priceEl).removeClass('box_shadow');
      //$(this.priceDollarEl).addClass('creation_dollar_inactive');
    }
    else {
      //$(this.priceEl).removeClass('creation_input_inactive');
      $(this.priceEl).removeAttr('disabled');
      //$(this.isGiftBoxEl).removeClass('creation_checkbox_right_active');
      //$(this.priceEl).addClass('box_shadow');
      //$(this.priceDollarEl).removeClass('creation_dollar_inactive');
    }
  },

  // Returns the current state of the is unknown check box
  //
  isStoreUnknown: function() {
    return this.isStoreUnknownEl.is(':checked');
  },

  // Fired when the user toggles the is store unknown check box
  //
  isStoreUnknownChanged: function() {
   if(this.isStoreUnknown()) {
      $(this.storeEl).val('');
      //$(this.storeEl).removeClass('box_shadow');
      //$(this.storeEl).addClass('creation_input_inactive');
      this.storeEl.attr('disabled','disabled');
      //$(this.isStoreUnknownBoxEl).addClass('creation_checkbox_right_active');
    }
    else {
      //$(this.storeEl).addClass('box_shadow');
      //$(this.storeEl).removeClass('creation_input_inactive');
      this.storeEl.removeAttr('disabled');
      //$(this.isStoreUnknownBoxEl).removeClass('creation_checkbox_right_active');
    }
  }

});
