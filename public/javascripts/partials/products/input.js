// Partial for creating or editing a product
//
Denwen.Partials.Products.Input = Backbone.View.extend({

  // Event listeners
  //
  events: {
    "click #endorsement_initiate" : "endorsementInitiated",
    "keypress #product_title" : "inputKeystroke",
    "keypress #product_store_name" : "inputKeystroke",
    "change #product_is_store_unknown" : "isStoreUnknownChanged"
  },

  // Constructor logic
  //
  initialize: function() {
    var self                  = this;
    this.mode                 = this.options.mode;

    this.formEl               = '#' + this.mode + '_product';
    this.queryEl              = '#product_query';
    this.queryBoxEl           = '#query_box';
    this.queryTextEl          = '#query_text';
    this.extraEl              = '#extra_steps';
    this.onboardingEl         = '#onboarding';
    this.onboardingMsgEl      = '#onboarding_create_msg';
    this.titleEl              = '#product_title';
    this.titleTextEl          = '#title_text';
    this.storeEl              = '#product_store_name';
    this.storeBoxEl           = '#store_box';
    this.storeTextEl          = '#store_text';
    this.websiteEl            = '#product_source_url';
    this.thumbEl              = '#product_orig_thumb_url';
    this.imageEl              = '#product_orig_image_url';
    this.imageBrokenMsgEl     = '#product_image_broken_msg';
    this.selectionEl          = '#product_selection';
    this.photoSelectionEl     = 'product_selection_photo';
    this.endorsementEl        = '#product_endorsement';
    this.endorsementBoxEl     = '#endorsement_container';
    this.endorsementStartEl   = '#endorsement_initiate';
    this.isStoreUnknownEl     = '#product_is_store_unknown';
    this.isStoreUnknownBoxEl  = '#is_store_unknown_box';
    this.posting              = false;

    this.productImages      = new Denwen.Collections.ImageResults();
    this.productImagesView  = new Denwen.Partials.Products.ImageResults({
                                  el:this.el,
                                  images:this.productImages,
                                  mode:this.mode});
    this.productImagesView.bind('productSelected',this.productSelected,this);
    this.productImagesView.bind('productSearched',this.productSearched,this);
    this.productImagesView.bind('productSearchCancelled',
                                this.productSearchCancelled,this);

    $(this.formEl).submit(function(){return self.post();});

    restrictFieldSize($(this.storeEl),254,'charsremain');

    new Denwen.Partials.Stores.Autocomplete({el:$(this.storeEl)});
  },

  // Catch keystrokes on inputs to stop form submissions
  //
  inputKeystroke: function(e) {
    if(e.keyCode == 13) {
      return false;
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
      $(this.storeEl).val('');
      $(this.storeEl).removeClass('box_shadow');
      $(this.storeEl).addClass('creation_input_inactive');
      $(this.storeEl).attr('disabled','disabled');
      $(this.isStoreUnknownBoxEl).addClass('creation_checkbox_right_active');
    }
    else {
      $(this.storeEl).addClass('box_shadow');
      $(this.storeEl).removeClass('creation_input_inactive');
      $(this.storeEl).removeAttr('disabled');
      $(this.isStoreUnknownBoxEl).removeClass('creation_checkbox_right_active');
    }
  },

  // User initiate creation of endorsement
  //
  endorsementInitiated: function() {
    this.displayEndorsement(false,'');
  },

  // Display the endorsement UI without optional text and analytics
  //
  displayEndorsement: function(isRobot,endorsement) {

    $(this.endorsementStartEl).hide();
    $(this.endorsementBoxEl).show();

    if(endorsement)
      $(this.endorsementEl).val(endorsement);
    else
      $(this.endorsementEl).focus();

    if(!isRobot)
      analytics.endorsementCreationSelected(this.mode);
  },

  // Display product image 
  //
  displayProductImage: function(imageURL) {
    $(this.selectionEl).show();
    $(this.selectionEl).html("<img class='photo' id='" + this.photoSelectionEl + "' src='" + imageURL + "' />");
  },

  // Fired when a product is selected from the ProductImagesView
  //
  productSelected: function(productHash) {
    var self = this;
    
    this.displayProductImage(productHash['image_url']);

    document.getElementById(this.photoSelectionEl).onerror = function(){self.productImageBroken()};

    $(this.websiteEl).val(productHash['website_url']);
    $(this.imageEl).val(productHash['image_url']);
    $(this.thumbEl).val(productHash['thumb_url']);

    $(this.queryBoxEl).hide();
    $(this.onboardingEl).hide();
    $(this.onboardingMsgEl).hide();
    $(this.imageBrokenMsgEl).hide();

    $(this.extraEl).show();
    $(this.titleEl).focus();
    $(this.titleEl).val(productHash['query'].toProperCase());

    analytics.productSearchCompleted(this.mode);
  },

  // Fired when a product is searched from the ProductImagesView
  //
  productSearched: function(query,queryType) {
    analytics.productSearched(query,queryType,this.mode);
  },

  // Fired when a product search is cancelled
  //
  productSearchCancelled: function(source) {
    analytics.productSearchCancelled(source,this.mode);
  },

  // Fired when a product image is broken
  //
  productImageBroken: function() {
    $(this.selectionEl).hide();
    $(this.selectionEl).html('');
    $(this.imageEl).val('');
    $(this.thumbEl).val('');

    $(this.queryEl).focus();
    $(this.queryBoxEl).show();
    $(this.imageBrokenMsgEl).show();

    this.productImagesView.search();

    analytics.productImageBroken(this.mode);
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

      $(this.queryEl).addClass('incomplete');
      $(this.queryTextEl).addClass('incomplete');
      analytics.productException('No Photo',this.mode);
    }
    else {
      $(this.queryEl).removeClass('incomplete');
      $(this.queryTextEl).removeClass('incomplete');
    }

    if($(this.titleEl).val().length < 1) {
      valid = false;

      $(this.titleEl).addClass('incomplete');
      $(this.titleTextEl).addClass('incomplete');
      analytics.productException('No Title',this.mode);
    }
    else {
      $(this.titleEl).removeClass('incomplete');
      $(this.titleTextEl).removeClass('incomplete');
    }

    if(!this.isStoreUnknown() && $(this.storeEl).val().length < 1) {
      valid = false;

      $(this.storeEl).addClass('incomplete');
      $(this.storeTextEl).addClass('incomplete');
      analytics.productException('No Store',this.mode);
    }
    else {
      $(this.storeEl).removeClass('incomplete');
      $(this.storeTextEl).removeClass('incomplete');
    }

    this.posting = valid;
      
    return valid;
  }
});


