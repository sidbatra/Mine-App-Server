// View for creating a new product
//
Denwen.ProductInputView = Backbone.View.extend({

  // Event listeners
  //
  events: {
    "click #endorsement_initiate" : "endorsementInitiated",
    "keypress #product_title" : "inputKeystroke",
    "keypress #product_store" : "inputKeystroke",
    "keypress #product_price" : "inputKeystroke",
    "change #product_is_gift" : "isGiftChanged",
    "change #product_is_store_unknown" : "isStoreUnknownChanged"
  },

  // Constructor logic
  //
  initialize: function() {
    var self          = this;

    this.formEl               = '#new_product';
    this.queryEl              = '#product_query';
    this.titleEl              = '#product_title';
    this.dollarEL             = '#creation_dollar';
    this.priceEl              = '#product_price';
    this.priceTextEl          = '#price_text';
    this.priceBoxEl           = '#price_box';
    this.storeEl              = '#product_store';
    this.storeTextEl          = '#store_text';
    this.storeBoxEl           = '#store_box';
    this.websiteEl            = '#product_source_url';
    this.thumbEl              = '#product_orig_thumb_url';
    this.imageEl              = '#product_orig_image_url';
    this.extraEl              = '#product_extra';
    this.selectionEl          = '#product_selection';
    this.endorsementEl        = '#product_endorsement';
    this.endorsementBoxEl     = '#endorsement_container';
    this.endorsementStartEl   = '#endorsement_initiate';
    this.isGiftEl             = '#product_is_gift';
    this.isGiftBoxEl          = '#is_gift_box';
    this.isStoreUnknownEl     = '#product_is_store_unknown';
    this.isStoreUnknownBoxEl  = '#is_store_unknown_box';
    this.posting              = false;

    this.productImages      = new Denwen.ProductImages();
    this.productImagesView  = new Denwen.ProductImagesView({
                                  el:$('body'),
                                  images:this.productImages});
    this.productImagesView.bind('productSelected',this.productSelected,this);

    $(this.formEl).submit(function(){return self.post();});

    restrictFieldSize($(this.priceEl),11,'charsremain');
    restrictFieldSize($(this.storeEl),254,'charsremain');
  },

  // Catch keystrokes on inputs to stop form submissions
  //
  inputKeystroke: function(e) {
    if(e.keyCode == 13) {
      return false;
    }
  },

  // Returns the current state of the gifted check box
  //
  isGifted: function() {
    return $(this.isGiftEl).is(':checked');
  },

  // Fired when the user toggles the is gift check box
  //
  isGiftChanged: function() {
    if(this.isGifted()) {
      $(this.priceEl).hide();
      $(this.dollarEL).hide();
      $(this.priceTextEl).hide();
      $(this.priceEl).val('0');
      $(this.isGiftBoxEl).addClass('creation_checkbox_left');
    }
    else {
      $(this.isGiftBoxEl).removeClass('creation_checkbox_left');
      $(this.priceEl).val('');
      $(this.dollarEL).show();
      $(this.priceTextEl).show();
      $(this.priceEl).show();
    }
  },

  // Returns the current state of the is unknown check box
  //
  isStoreUnknown: function() {
    return $(this.isStoreUnknownEl).is(':checked');
  },

  // Fired when the user toggles the is store unknown check box
  //
  isStoreUnknownChanged: function() {
    if(this.isStoreUnknown()) {
      $(this.storeEl).hide();
      $(this.storeTextEl).hide();
      $(this.isStoreUnknownBoxEl).addClass('creation_checkbox_left');
    }
    else {
      $(this.isStoreUnknownBoxEl).removeClass('creation_checkbox_right');
      $(this.storeEl).show();
      $(this.storeTextEl).show();
    }
  },

  // User initiate creation of endorsement
  //
  endorsementInitiated: function() {
    $(this.endorsementStartEl).hide();
    $(this.endorsementBoxEl).show();
    $(this.endorsementEl).focus();

    analytics.endorsementCreationSelected();
  },

  // Fired when a product is selected from the ProductImagesView
  //
  productSelected: function(productHash) {
    var self = this;

    $(this.selectionEl).show();
    $(this.selectionEl).html("<img id='product_selection_photo' src='" + productHash['image_url'] + "' />");

    document.getElementById('product_selection_photo').onerror = function(){self.productImageBroken()};

    $(this.websiteEl).val(productHash['website_url']);
    $(this.imageEl).val(productHash['image_url']);
    $(this.thumbEl).val(productHash['thumb_url']);

    $(this.extraEl).show();

    $(this.titleEl).focus();
    $(this.titleEl).val(productHash['query'].toProperCase());

    analytics.productSearchCompleted();
  },

  // Fired when a product image is broken
  //
  productImageBroken: function() {
    $(this.selectionEl).hide();
    $(this.selectionEl).html('');
    $(this.imageEl).val('');
    $(this.thumbEl).val('');

    $(this.queryEl).focus();

    this.productImagesView.search();

    alert("Sorry, this image no longer exists. Please select again");

    analytics.productImageBroken();
  },

  // Form submitted callback
  //
  post: function() {
	
    if(this.posting)
      return false;

    this.posting  = true;
    var valid     = true;

    if($(this.imageEl).val().length < 1) {
      valid = false;
      alert("Please search for a photo of your item.");
      analytics.productException('No Photo');
    }
    else if($(this.titleEl).val().length < 1) {
      valid = false;
      alert("Please name your item.");
      analytics.productException('No Title');
    }
    else if(!this.isGifted() && $(this.priceEl).val().length < 1) {
      valid = false;
      alert("Please enter the price of your item.");
      analytics.productException('No Price');
    }
    else if(!this.isGifted() && isNaN($(this.priceEl).val())) {
      valid = false;
      alert("Please enter a valid price.");
      analytics.productException('Invalid Price');
    }
    else if(!this.isStoreUnknown() && $(this.storeEl).val().length < 1) {
      valid = false;
      alert("Please enter the store where you bought this item.");
      analytics.productException('No Store');
    }

    this.posting = valid;
      
    return valid;
  }
});

