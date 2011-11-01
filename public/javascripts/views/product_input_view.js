// View for creating a new product
//
Denwen.ProductInputView = Backbone.View.extend({

  // Event listeners
  //
  events: {
    "submit #new_product" : "post"
  },

  // Constructor logic
  //
  initialize: function() {
    this.queryEl      = '#product_query';
    this.titleEl      = '#product_title';
    this.priceEl      = '#product_price';
    this.storeEl      = '#product_store';
    this.websiteEl    = '#product_website_url';
    this.thumbEl      = '#product_thumb_url';
    this.imageEl      = '#product_image_url';
    this.extraEl      = '#product_extra';
    this.selectionEl  = '#product_selection';
    this.posting      = false;

    this.productImages      = new Denwen.ProductImages();
    this.productImagesView  = new Denwen.ProductImagesView({
                                  el:$('body'),
                                  images:this.productImages});
    this.productImagesView.bind('productSelected',this.productSelected,this);

    restrictFieldSize($(this.priceEl),11,'charsremain');
    restrictFieldSize($(this.storeEl),254,'charsremain');
  },

  // Fired when a product is selected from the ProductImagesView
  //
  productSelected: function(productHash) {
    $(this.selectionEl).show();
    $(this.selectionEl).html("<img id='product_selection_photo' src='" + productHash['image_url'] + "' />");

    $(this.websiteEl).val(productHash['website_url']);
    $(this.imageEl).val(productHash['image_url']);
    $(this.thumbEl).val(productHash['thumb_url']);

    $(this.extraEl).show();

    $(this.titleEl).focus();
    $(this.titleEl).val(productHash['query'].toProperCase());

    analytics.productSearchCompleted();
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
    else if($(this.priceEl).val().length < 1) {
      valid = false;
      alert("Please enter the price of your item.");
      analytics.productException('No Price');
    }
    else if(isNaN($(this.priceEl).val())) {
      valid = false;
      alert("Please enter a valid price.");
      analytics.productException('Invalid Price');
    }
    else if($(this.storeEl).val().length < 1) {
      valid = false;
      alert("Please enter the store where you bought this item.");
      analytics.productException('No Store');
    }

    this.posting = valid;
      
    return valid;
  }
});

