var Product = Backbone.Model.extend({

  initialize: function(){
  }

});


var ProductInputView = Backbone.View.extend({

  events: {
    "submit #new_product" : "post"
  },

  initialize: function() {
    this.titleEl = '#product_title';
    this.endorsementEl = '#product_endorsement';
    this.queryEl = '#product_query';
    this.websiteEl = '#product_website_url';
    this.thumbEl = '#product_thumb_url';
    this.imageEl = '#product_image_url';
    this.extraEl = '#product_extra';
    this.selectionEl = '#product_selection';

    this.productImages = new ProductImages();
    this.productImagesView = new ProductImagesView({
                                  el:$('body'),
                                  images:this.productImages});
    this.productImagesView.bind('productSelected',this.productSelected,this);
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
  },

  post: function() {
    console.log("submitted");
  }
});
