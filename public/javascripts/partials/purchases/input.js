// Partial for creating or editing a purchase
//
Denwen.Partials.Purchases.Input = Backbone.View.extend({

  // Event listeners
  //
  events: {
    "keypress #purchase_title" : "inputKeystroke",
    "keypress #purchase_store_name" : "inputKeystroke",
    "change #purchase_is_store_unknown" : "isStoreUnknownChanged",
    "mousedown #fb-photo-toggle-switch" : "switchToggled",
    "click #initiate_endorsement" : "endorsementInitiated",
    "click #initiate_purchase" : "purchaseInitiated"
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
    this.initPurchaseEl       = '#initiate_purchase';
    this.queryEl              = '#purchase_query';
    this.querySubBoxEl        = '#query_sub_box';
    this.queryBoxEl           = '#query_box';
    this.queryTextEl          = '#query_text';
    this.extraEl              = '#extra_steps';
    this.onboardingEl         = '#onboarding';
    this.onboardingMsgEl      = '#onboarding_create_msg';
    this.titleEl              = '#purchase_title';
    this.titleBoxEl           = '#title_box';
    this.productTitleEl       = '#purchase_product_title';
    this.productExternalIDEl  = '#purchase_product_external_id';
    this.storeEl              = '#purchase_store_name';
    this.storeBoxEl           = '#store_box';
    this.initEndorsementEl    = '#initiate_endorsement';
    this.endorsementEl        = '#purchase_endorsement';
    this.websiteEl            = '#purchase_source_url';
    this.thumbEl              = '#purchase_orig_thumb_url';
    this.imageEl              = '#purchase_orig_image_url';
    this.imageBrokenMsgEl     = '#purchase_image_broken_msg';
    this.selectionEl          = '#purchase_selection';
    this.photoSelectionEl     = 'purchase_selection_photo';
    this.isStoreUnknownEl     = '#purchase_is_store_unknown';
    this.isStoreUnknownBoxEl  = '#is_store_unknown_box';
    this.urlAlertBoxEl        = '#url_alert_box';
    this.suggestionEl         = '#purchase_suggestion_id';
    this.switchEl             = '#fb-photo-toggle-switch';
    this.submitButtonEl       = '#submit-button';
    this.switchOffClass       = 'off';
    this.postingClass         = 'load';
    this.posting              = false;

    this.productSearch  = new Denwen.Partials.Products.Search({
                                  el:this.el,
                                  mode:this.mode});

    this.productSearch.bind(
      Denwen.Partials.Products.Search.Callback.ProductSelected,
      this.productSelected,
      this);

    this.productSearch.bind(
      Denwen.Partials.Products.Search.Callback.ProductSearched,
      this.productSearched,
      this);

    this.productSearch.bind(
      Denwen.Partials.Products.Search.Callback.Cancelled,
      this.productSearchCancelled,
      this);


    this.fbPermissionsRequired = 'fb_publish_permissions';

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
    this.autoComplete.bind(
      Denwen.Partials.Stores.Autocomplete.Callback.StoresLoaded,
      this.storesLoaded,
      this);

    $(this.storeEl).placeholder();
    $(this.titleEl).placeholder();
  },

  // Callback from autocomplete when stores are loaded
  //
  storesLoaded: function(stores) {
    this.stores = stores;
  },

  // User initiates a purchase.
  //
  purchaseInitiated: function() {
    $(this.initPurchaseEl).hide();
    $(this.querySubBoxEl).show();

    $(this.queryEl).phocus();

    Denwen.Track.action("Purchase Initiated");
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

    if(this.switchState())
      Denwen.Track.action("Purchase FB Photo On");
    else
      Denwen.Track.action("Purchase FB Photo Off");
  },

  // User initiates endorsements.
  //
  endorsementInitiated: function(e) {
    $(this.initEndorsementEl).hide();
    $(this.endorsementEl).show();

    if(!e)
      return;

    $(this.endorsementEl).focus();

    Denwen.Track.action("Purchase Endorsement Initiated");
  },

  // Display purchase image 
  //
  displayPurchaseImage: function(imageURL) {
    $(this.selectionEl).show();
    $(this.selectionEl).html("<img id='" + this.photoSelectionEl + "' src='" + imageURL + "' />");
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
    }
    else {
      $(this.queryEl).removeClass('incomplete');
      $(this.queryTextEl).removeClass('incomplete');
    }

    if($(this.titleEl).val().length < 1 || 
        $(this.titleEl).val() == $(this.titleEl).attr('placeholder')) {
      valid = false;

      $(this.titleBoxEl).addClass('error');
      Denwen.Track.purchaseValidationError('No Title');
    }
    else {
      $(this.titleBoxEl).removeClass('error');
    }

    if(!this.isStoreUnknown() && ($(this.storeEl).val().length < 1 || 
          $(this.storeEl).val() == $(this.storeEl).attr('placeholder'))) {
      valid = false;

      $(this.storeBoxEl).addClass('error');
      Denwen.Track.purchaseValidationError('No Store');
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
    var fields = {product:{}};

    $(this.submitButtonEl).addClass(this.postingClass);

    inputs.each(function() {
      if(this.id.slice(0,17) == 'purchase_product_')
        fields['product'][this.id.slice(17)] = this.value;
      else if(this.id.slice(0,9) == 'purchase_')
        fields[this.id.slice(9)] = this.value;
    });

    var purchase = new Denwen.Models.Purchase();

    fields['is_store_unknown'] = this.isStoreUnknown() ? '1' : '0';
    fields['post_to_timeline'] = this.switchState(); 

    purchase.save({purchase:fields},{
      success: function(data){self.purchaseCreated(data);},
      error: function(){self.purchaseCreationFailed();}});
    
    return false;
  },


  //
  // Callbacks from fb permissions interface.
  //

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


  //
  // Callbacks from purchase creation.
  //

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
    $(this.querySubBoxEl).hide();
    $(this.initPurchaseEl).show();

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
  },


  //
  // Callbacks from product search.
  //

  // Fired when a product is selected 
  //
  productSelected: function(product,title,attemptStoreSearch) {
    var self = this;

    this.searchesCount = 0;

    this.displayPurchaseImage(product.get('large_url'));

    document.getElementById(this.photoSelectionEl).onerror = function(){self.productImageBroken()};

    $(this.websiteEl).val(product.get('source_url'));
    $(this.imageEl).val(product.get('large_url'));
    $(this.thumbEl).val(product.get('medium_url'));

    $(this.productTitleEl).val(product.get('title'));
    $(this.productExternalIDEl).val(product.get('uniq_id'));

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

    Denwen.Track.action("Product Selected");

    // Test if the website url matches a known store to populate
    // the store field
    //
    if(attemptStoreSearch) {
      var sourceURL = product.get('source_url').toLowerCase();

      if(this.stores) {
        this.stores.each(function(store){
          if(store.get('domain') && sourceURL.search(store.get('domain')) != -1) 
            $(self.storeEl).val(store.get('name'));
        });
      }
    } //attempt store search
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

    this.productSearch.search();

    Denwen.Track.action("Product Image Broken");
  },

  // Fired when a product is searched from the ProductsImageView
  //
  productSearched: function(query,queryType) {
    this.searchesCount++;

    Denwen.Track.action("Product Search Started",{"Query Type" : queryType});

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
    Denwen.Track.action("Product Search Cancelled",{"Source" : source});
  },

  // Launch search via a suggestion.
  //
  // query - The String to be searched.
  // suggestionID - The Integer id for the suggestion that launched the search.
  //
  searchViaSuggestion: function(query,suggestionID) {
    $(this.queryEl).val(query);
    $(this.suggestionEl).val(suggestionID);

    this.productSearch.search();
  }

});

// Define callbacks.
//
Denwen.Partials.Purchases.Input.Callback = {
  PurchaseCreated: "purchaseCreated",
  PurchaseCreationFailed: "purchaseCreationFailed"
};
