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

    this.productID    = this.options.product_id;
    this.posting      = false;
    this.autocomplete = null;

    this.render();

    this.boxEl                = $('#own_box_' + this.productID);
    this.priceEl              = $('#product_price_' + this.productID);
    this.priceBoxEl           = $('#product_price_box_' + this.productID);
    this.priceTextEl          = $('#product_price_text_' + this.productID);
    this.priceDollarEl        = $('#creation_dollar_' + this.productID);
    this.storeEl              = $('#product_store_name_' + this.productID);
    this.storeBoxEl           = $('#product_store_box_' + this.productID);
    this.storeTextEl          = $('#product_store_text_' + this.productID);
    this.isGiftEl             = $('#product_is_gift_' + this.productID);
    this.isStoreUnknownEl     = $('#product_is_store_unknown_'+ this.productID);

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
    this.storeEl.focus();

    if(this.autocomplete == null)
      this.autocomplete = new Denwen.Partials.Stores.Autocomplete({
                                el:this.storeEl});
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
    var mode  = 'own';

    if(!this.isGifted() && 
            $(this.priceEl).val().replace(/ /g,'').length < 1) {
      valid = false;

      this.priceEl.addClass('incomplete');
      this.priceTextEl.addClass('incomplete');
      this.priceDollarEl.addClass('incomplete');

      analytics.productException('No Price',mode);
    }
    else if(!this.isGifted() && isNaN(this.priceEl.val())) {
      valid = false;

      this.priceEl.addClass('incomplete');
      this.priceTextEl.addClass('incomplete');
      this.priceDollarEl.addClass('incomplete');
      
      analytics.productException('Invalid Price',mode);
    }
    else {
      this.priceEl.removeClass('incomplete');
      this.priceTextEl.removeClass('incomplete');
      this.priceDollarEl.removeClass('incomplete');
    }

    
    if(!this.isStoreUnknown() && this.storeEl.val().length < 1) {
      valid = false;

      this.storeEl.addClass('incomplete');
      this.storeTextEl.addClass('incomplete');

      analytics.productException('No Store',mode);
    }
    else {
      this.storeEl.removeClass('incomplete');
      this.storeTextEl.removeClass('incomplete');
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
      this.priceBoxEl.addClass('inactive');
      this.priceEl.attr('disabled','disabled');
    }
    else {
      this.priceBoxEl.removeClass('inactive');
      $(this.priceEl).removeAttr('disabled');
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
      this.storeBoxEl.addClass('inactive');
      this.storeEl.attr('disabled','disabled');
    }
    else {
      this.storeBoxEl.removeClass('inactive');
      this.storeEl.removeAttr('disabled');
    }
  }

});
