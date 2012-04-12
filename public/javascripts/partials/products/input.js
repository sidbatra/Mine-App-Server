// Partial for creating or editing a product
//
Denwen.Partials.Products.Input = Backbone.View.extend({

  // Event listeners
  //
  events: {
    "keypress #product_title" : "inputKeystroke",
    "keypress #product_store_name" : "inputKeystroke",
    "change #product_is_store_unknown" : "isStoreUnknownChanged",
    "mousedown #fb-photo-toggle-switch" : "switchToggled"
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
    this.isStoreUnknownEl     = '#product_is_store_unknown';
    this.isStoreUnknownBoxEl  = '#is_store_unknown_box';
    this.sourceProductIDEl    = '#product_source_product_id';
    this.urlAlertBoxEl        = '#url_alert_box';
    this.switchEl             = '#fb-photo-toggle-switch';
    this.posting              = false;

    this.productImagesView  = new Denwen.Partials.Products.ImageResults({
                                  el:this.el,
                                  mode:this.mode});
    this.productImagesView.bind('productSelected',this.productSelected,this);
    this.productImagesView.bind('productSearched',this.productSearched,this);
    this.productImagesView.bind('productSearchCancelled',
                                this.productSearchCancelled,this);

    this.fbPermissionsRequired = 'fb_extended_permissions';

    this.fbSettings = new Denwen.Partials.Settings.Facebook({
                            permissions : this.fbPermissionsRequired});

    this.fbSettings.bind(
                      'fbPermissionsAccepted',
                      this.fbPermissionsAccepted,
                      this);

    this.fbSettings.bind(
                      'fbPermissionsRejected',
                      this.fbPermissionsRejected,
                      this);

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

  // Returns the current state of the facebook photo toggle switch
  // on -> true & off -> false
  //
  switchState: function() {
    return !$(this.switchEl).hasClass('off');
  },

  // Fired when the fb photo switch is toggled
  //
  switchToggled: function() {
    if(!Denwen.H.currentUser.get('setting').get(this.fbPermissionsRequired)) 
      this.fbSettings.showPermissionsDialog();

    $(this.switchEl).toggleClass("off");    
  },

  // Fired when fb permissions are accepted 
  //
  fbPermissionsAccepted: function() {
  },

  // Fired when fb permissions are rejected
  //
  fbPermissionsRejected: function() {
    $(this.switchEl).toggleClass("off");    
    Denwen.Drawer.error("Please allow Facebook permissions for posting photos.");
  },

  // Display product image 
  //
  displayProductImage: function(imageURL) {
    $(this.selectionEl).show();
    $(this.selectionEl).html("<img class='photo' id='" + this.photoSelectionEl + "' src='" + imageURL + "' />");
  },

  // Hide and clean the product image box.
  //
  hideProductImage: function() {
    $(this.selectionEl).hide();
    $(this.selectionEl).html("");
  },

  // Display the query box area.
  //
  displayQueryBox: function() {
    $(this.queryBoxEl).show();
  },

  // Hide the UI displaying extra steps.
  //
  hideExtraSteps: function() {
    $(this.extraEl).hide();
  },

  // Reset UI and values of all form fields.
  //
  resetForm: function() {
    $(this.formEl)[0].reset();
    this.posting = false;
    this.isStoreUnknownChanged();
  },

  // Fired when a product is selected from the ProductImagesView
  //
  productSelected: function(productResult,title,attemptStoreSearch) {
    var self = this;

    this.searchesCount = 0;

    this.displayProductImage(productResult.get('large_url'));

    document.getElementById(this.photoSelectionEl).onerror = function(){self.productImageBroken()};

    $(this.websiteEl).val(productResult.get('source_url'));
    $(this.imageEl).val(productResult.get('large_url'));
    $(this.thumbEl).val(productResult.get('medium_url'));
    $(this.sourceProductIDEl).val(productResult.get('uniq_id'));

    $(this.queryBoxEl).hide();
    $(this.onboardingEl).hide();
    $(this.onboardingMsgEl).hide();
    $(this.imageBrokenMsgEl).removeClass('error');

    $(this.extraEl).show();
    $(this.titleEl).val(title.replace(/^\s+|\s+$/g, '').toProperCase());

    if(title.length)
      $(this.storeEl).focus();
    else
      $(this.titleEl).focus();

    $(this.urlAlertBoxEl).hide();

    Denwen.Track.productSearchCompleted(this.mode);

    // Test if the website url matches a known store to populate
    // the store field
    //
    if(attemptStoreSearch) {
      var sourceURL = productResult.get('source_url').toLowerCase();

      if(this.stores) {
        this.stores.each(function(store){
          if(store.get('domain') && sourceURL.search(store.get('domain')) != -1) 
            $(self.storeEl).val(store.get('name'));
        });
      }
    } //attempt store search
  },

  // Fired when a product is searched from the ProductImagesView
  //
  productSearched: function(query,queryType) {
    this.searchesCount++;
    Denwen.Track.productSearched(query,queryType,this.mode);

    if(queryType == Denwen.ProductQueryType.Text) {
      
      if(query.split(' ').length == 1 && !this.oneWordToolTipDone) {
        Denwen.Drawer.info(CONFIG['one_word_query_msg'],0);
        this.oneWordToolTipDone = true;
      }
      else if(this.searchesCount == CONFIG['multi_query_threshold'] && 
                !this.urlToolTipDone) {
        Denwen.Drawer.info(CONFIG['multi_query_msg'],0);
        this.urlToolTipDone = true;
      }
    }
  },

  // Fired when a product search is cancelled
  //
  productSearchCancelled: function(source) {
    this.searchesCount = 0;
    Denwen.Track.productSearchCancelled(source,this.mode);
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

    Denwen.Track.productImageBroken(this.mode);
  },

  // Validate the fields of the form.
  //
  // returns - Boolean. true if validation is successfuly.
  //
  validate: function() {
    var valid = true;

    if($(this.imageEl).val().length < 1) {
      valid = false;

      $(this.queryEl).addClass('incomplete');
      $(this.queryTextEl).addClass('incomplete');
      Denwen.Track.productException('No Photo',this.mode);
    }
    else {
      $(this.queryEl).removeClass('incomplete');
      $(this.queryTextEl).removeClass('incomplete');
    }

    if($(this.titleEl).val().length < 1) {
      valid = false;

      $(this.titleBoxEl).addClass('error');
      Denwen.Track.productException('No Title',this.mode);
    }
    else {
      $(this.titleBoxEl).removeClass('error');
    }

    if(!this.isStoreUnknown() && $(this.storeEl).val().length < 1) {
      valid = false;

      $(this.storeBoxEl).addClass('error');
      Denwen.Track.productException('No Store',this.mode);
    }
    else {
      $(this.storeBoxEl).removeClass('error');
    }

    return valid;
  },

  // Intercept the callback when the form is submitted and
  // create a product via js always returning false to stop
  // the form submission chain.
  //
  // returns - Boolean. During mode new false to stop the form submission chain.
  //                    During mode edit true to use html form submissions.
  //
  post: function() {
	
    if(this.posting)
      return false;

    this.posting = this.validate();

    if(!this.posting)
      return false;

    if(this.mode == Denwen.ProductFormType.Edit)
      return true;

    var self = this;
    var inputs = $(this.formEl + " :input");
    var fields = {};

    inputs.each(function() {
      if(this.id.slice(0,8) == 'product_')
        fields[this.id.slice(8)] = this.value;
    });

    var product = new Denwen.Models.Product();

    fields['is_store_unknown'] = this.isStoreUnknown() ? '1' : '0';
    fields['post_to_fb_album'] = this.switchState(); 

    product.save({product:fields},{
      success: function(data){self.productCreated(data);},
      error: function(){self.productCreationFailed();}});
      
    return false;
  },

  // Callback after a product is successfully created.
  // Wipe the form clean and trigger events for subscribers.
  //
  // product - Backbone.Model. Freshly created product.
  //
  productCreated: function(product) {
    this.hideProductImage();
    this.hideExtraSteps();
    this.resetForm();
    this.displayQueryBox();
    $(this.queryEl).focus();

    this.trigger(
      Denwen.Partials.Products.Input.Callback.ProductCreated,
      product);
  },

  // Callback after a production creation failed.
  // Trigger events alerting subscribers.
  //
  productCreationFailed: function() {
    this.trigger(
      Denwen.Partials.Products.Input.Callback.ProductCreationFailed);
  }
});

// Define callbacks.
//
Denwen.Partials.Products.Input.Callback = {
  ProductCreated: "productCreated",
  ProductCreationFailed: "productCreationFailed"
};
