// Partial for creating or editing a purchase
//
Denwen.Partials.Purchases.Input = Backbone.View.extend({

  // Event listeners
  //
  events: {
    "keypress #purchase_title" : "inputKeystroke",
    "keypress #purchase_store_name" : "inputKeystroke",
    "change #purchase_is_store_unknown" : "isStoreUnknownChanged",
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

    this.formEl               = '#' + this.mode + '_purchase';
    this.queryEl              = '#purchase_query';
    this.queryBoxEl           = '#query_box';
    this.queryTextEl          = '#query_text';
    this.extraEl              = '#extra_steps';
    this.onboardingEl         = '#onboarding';
    this.onboardingMsgEl      = '#onboarding_create_msg';
    this.titleEl              = '#purchase_title';
    this.titleBoxEl           = '#title_box';
    this.storeEl              = '#purchase_store_name';
    this.storeBoxEl           = '#store_box';
    this.websiteEl            = '#purchase_source_url';
    this.thumbEl              = '#purchase_orig_thumb_url';
    this.imageEl              = '#purchase_orig_image_url';
    this.imageBrokenMsgEl     = '#product_image_broken_msg';
    this.selectionEl          = '#product_selection';
    this.photoSelectionEl     = 'product_selection_photo';
    this.isStoreUnknownEl     = '#purchase_is_store_unknown';
    this.isStoreUnknownBoxEl  = '#is_store_unknown_box';
    this.sourcePurchaseIDEl    = '#purchase_source_product_id';
    this.urlAlertBoxEl        = '#url_alert_box';
    this.switchEl             = '#fb-photo-toggle-switch';
    this.submitButtonEl       = '#submit-button';
    this.switchOffClass       = 'off';
    this.postingClass         = 'load';
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
      Denwen.Partials.Settings.Facebook.Callback.PermissionsAccepted,
      this.fbPermissionsAccepted,
      this);

    this.fbSettings.bind(
      Denwen.Partials.Settings.Facebook.Callback.PermissionsRejected,
      this.fbPermissionsRejected,
      this);

    $(this.formEl).submit(function(){return self.post();});

    restrictFieldSize($(this.storeEl),254,'charsremain');

    this.autoComplete = new Denwen.Partials.Stores.Autocomplete(
                              {el:$(this.storeEl)});
    this.autoComplete.bind(Denwen.Callback.StoresLoaded,
          this.storesLoaded,this);

    $(this.storeEl).placeholder();
    $(this.titleEl).placeholder();
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
    return !$(this.switchEl).hasClass(this.switchOffClass);
  },

  // Fired when the fb photo switch is toggled
  //
  switchToggled: function() {
    if(!Denwen.H.currentUser.get('setting').get(this.fbPermissionsRequired)) 
      this.fbSettings.showPermissionsDialog();

    $(this.switchEl).toggleClass(this.switchOffClass);
  },

  // Fired when fb permissions are accepted 
  //
  fbPermissionsAccepted: function() {
  },

  // Fired when fb permissions are rejected
  //
  fbPermissionsRejected: function() {
    $(this.switchEl).toggleClass(this.switchOffClass);
    Denwen.Drawer.error("Please allow Facebook permissions for posting photos.");
  },

  // Display purchase image 
  //
  displayPurchaseImage: function(imageURL) {
    $(this.selectionEl).show();
    $(this.selectionEl).html("<img class='photo' id='" + this.photoSelectionEl + "' src='" + imageURL + "' />");
  },

  // Hide and clean the product image box.
  //
  hidePurchaseImage: function() {
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

  // Fired when a product is selected from the PurchaseImagesView
  //
  productSelected: function(productResult,title,attemptStoreSearch) {
    var self = this;

    this.searchesCount = 0;

    this.displayPurchaseImage(productResult.get('large_url'));

    document.getElementById(this.photoSelectionEl).onerror = function(){self.productImageBroken()};

    $(this.websiteEl).val(productResult.get('source_url'));
    $(this.imageEl).val(productResult.get('large_url'));
    $(this.thumbEl).val(productResult.get('medium_url'));
    $(this.sourcePurchaseIDEl).val(productResult.get('uniq_id'));

    $(this.queryBoxEl).hide();
    $(this.onboardingEl).hide();
    $(this.onboardingMsgEl).hide();
    $(this.imageBrokenMsgEl).removeClass('error');

    $(this.extraEl).show();

    var properTitle = title.replace(/^\s+|\s+$/g, '').toProperCase();

    if(properTitle.length)
      $(this.titleEl).val(properTitle);

    if($.support.placeholder)
      title.length ? $(this.storeEl).focus() : $(this.titleEl).focus();
    else if(title.length)
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

  // Fired when a product is searched from the ProductsImageView
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

    if($(this.titleEl).val().length < 1 || 
        $(this.titleEl).val() == $(this.titleEl).attr('placeholder')) {
      valid = false;

      $(this.titleBoxEl).addClass('error');
      Denwen.Track.productException('No Title',this.mode);
    }
    else {
      $(this.titleBoxEl).removeClass('error');
    }

    if(!this.isStoreUnknown() && ($(this.storeEl).val().length < 1 || 
          $(this.storeEl).val() == $(this.storeEl).attr('placeholder'))) {
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
  // create a purchase via js always returning false to stop
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

    if(this.mode == Denwen.PurchaseFormType.Edit)
      return true;

    var self = this;
    var inputs = $(this.formEl + " :input");
    var fields = {};

    $(this.submitButtonEl).addClass(this.postingClass);

    inputs.each(function() {
      if(this.id.slice(0,9) == 'purchase_')
        fields[this.id.slice(9)] = this.value;
    });

    var purchase = new Denwen.Models.Purchase();

    fields['is_store_unknown'] = this.isStoreUnknown() ? '1' : '0';
    fields['post_to_fb_album'] = this.switchState(); 

    purchase.save({purchase:fields},{
      success: function(data){self.purchaseCreated(data);},
      error: function(){self.purchaseCreationFailed();}});
      
    return false;
  },

  // Callback after a purchase is successfully created.
  // Wipe the form clean and trigger events for subscribers.
  //
  // purchase - Backbone.Model.Purchase. Freshly created purchase.
  //
  purchaseCreated: function(purchase) {
    this.hidePurchaseImage();
    $(this.submitButtonEl).removeClass(this.postingClass);
    this.hideExtraSteps();
    this.resetForm();
    this.displayQueryBox();
    $(this.queryEl).focus();

    this.trigger(
      Denwen.Partials.Purchases.Input.Callback.PurchaseCreated,
      purchase);
  },

  // Callback after a purchase  creation failed.
  // Trigger events alerting subscribers.
  //
  purchaseCreationFailed: function() {
    $(this.submitButtonEl).removeClass(this.postingClass);
    this.trigger(
      Denwen.Partials.Purchases.Input.Callback.PurchaseCreationFailed);
  }
});

// Define callbacks.
//
Denwen.Partials.Purchases.Input.Callback = {
  PurchaseCreated: "productCreated",
  PurchaseCreationFailed: "productCreationFailed"
};
