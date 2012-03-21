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
    this.searchesCount        = 0;
    this.oneWordToolTipDone   = false;
    this.urlToolTipDone       = false;

    this.formEl               = '#' + this.mode + '_product';
    this.queryEl              = '#product_query';
    this.queryBoxEl           = '#query_box';
    this.queryTextEl          = '#query_text';
    this.extraEl              = '#extra_steps';
    this.onboardingEl         = '#onboarding';
    this.onboardingMsgEl      = '#onboarding_create_msg';
    this.titleEl              = '#product_title';
    this.titleBoxEl           = '#title_box';
    this.storeEl              = '#product_store_name';
    this.storeBoxEl           = '#store_box';
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
    this.urlAlertBoxEl        = '#url_alert_box';
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

    this.autoComplete = new Denwen.Partials.Stores.Autocomplete(
                              {el:$(this.storeEl)});
    this.autoComplete.bind(Denwen.Callback.StoresLoaded,
          this.storesLoaded,this);
  },

  // Callback from autocomplete when stores are loaded
  //
  storesLoaded: function(stores) {
    this.stores = stores;
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

    this.searchesCount = 0;

    this.displayProductImage(productHash['image_url']);

    document.getElementById(this.photoSelectionEl).onerror = function(){self.productImageBroken()};

    $(this.websiteEl).val(productHash['website_url']);
    $(this.imageEl).val(productHash['image_url']);
    $(this.thumbEl).val(productHash['thumb_url']);

    $(this.queryBoxEl).hide();
    $(this.onboardingEl).hide();
    $(this.onboardingMsgEl).hide();
    $(this.imageBrokenMsgEl).removeClass('error');

    $(this.extraEl).show();
    $(this.storeEl).focus();
    $(this.titleEl).val(productHash['query'].toProperCase());

    $(this.urlAlertBoxEl).hide();

    analytics.productSearchCompleted(this.mode);

    // Test if the website url matches a known store to populate
    // the store field
    //
    var sourceURL = productHash['website_url'].toLowerCase();

    if(this.stores) {
      this.stores.each(function(store){
        if(store.get('domain') && sourceURL.search(store.get('domain')) != -1) 
          $(self.storeEl).val(store.get('name'));
      });
    }
  },

  // Fired when a product is searched from the ProductImagesView
  //
  productSearched: function(query,queryType) {
    this.searchesCount++;
    analytics.productSearched(query,queryType,this.mode);

    if(queryType == Denwen.ProductQueryType.Text) {
      
      if(query.split(' ').length == 1 && !this.oneWordToolTipDone) {
        dDrawer.info(CONFIG['one_word_query_msg'],0);
        this.oneWordToolTipDone = true;
      }
      else if(this.searchesCount == CONFIG['multi_query_threshold'] && 
                !this.urlToolTipDone) {
        dDrawer.info(CONFIG['multi_query_msg'],0);
        this.urlToolTipDone = true;
      }
    }
  },

  // Fired when a product search is cancelled
  //
  productSearchCancelled: function(source) {
    this.searchesCount = 0;
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
    $(this.extraEl).hide();
    $(this.imageBrokenMsgEl).addClass('error');

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

      $(this.titleBoxEl).addClass('error');
      analytics.productException('No Title',this.mode);
    }
    else {
      $(this.titleBoxEl).removeClass('error');
    }

    if(!this.isStoreUnknown() && $(this.storeEl).val().length < 1) {
      valid = false;

      $(this.storeBoxEl).addClass('error');
      analytics.productException('No Store',this.mode);
    }
    else {
      $(this.storeBoxEl).removeClass('error');
    }

    this.posting = valid;
      
    return valid;
  }
});


