// Partial for creating or editing a purchase
//
Denwen.Partials.Purchases.Input = Backbone.View.extend({

  // Event listeners
  //
  events: {
    "keypress #purchase_title" : "inputKeystroke",
    "keypress #purchase_store_name" : "inputKeystroke",
    "change #purchase_is_store_unknown" : "isStoreUnknownChanged",
    "click #fb-photo-toggle-switch" : "fbSwitchToggled",
    "click #tw-share-toggle-switch" : "twSwitchToggled",
    "click #tumblr-share-toggle-switch" : "tumblrSwitchToggled",
    "click #initiate_endorsement" : "endorsementInitiated",
    "click #initiate_purchase" : "purchaseInitiated"
  },

  // Constructor logic
  //
  initialize: function() {
    var self                  = this;
    this.mode                 = this.options.mode;
    this.scrollOnSelection    = this.options.scrollOnSelection == undefined ? 
                                  true : this.options.scrollOnSelection;
    this.resetOnCreation      = this.options.resetOnCreation == undefined ? 
                                  true : this.options.resetOnCreation;
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
    this.productTitleEl       = '#purchase_product_title';
    this.productExternalIDEl  = '#purchase_product_external_id';
    this.storeEl              = '#purchase_store_name';
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
    this.fbSwitchEl           = '#fb-photo-toggle-switch';
    this.twSwitchEl           = '#tw-share-toggle-switch';
    this.tumblrSwitchEl       = '#tumblr-share-toggle-switch';
    this.submitButtonEl       = '#submit-button';
    this.switchOffClass       = 'off';
    this.switchLoadingClass   = 'load';
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


    this.fbSettings = new Denwen.Partials.Settings.FBPublishPermissions();

    this.fbSettings.bind(
      Denwen.Partials.Settings.FBPublishPermissions.Callback.Accepted,
      this.fbPermissionsAccepted,
      this);

    this.fbSettings.bind(
      Denwen.Partials.Settings.FBPublishPermissions.Callback.Rejected,
      this.fbPermissionsRejected,
      this);


    this.fbAuth = new Denwen.Partials.Auth.Facebook();

    this.fbAuth.bind(
      Denwen.Partials.Auth.Facebook.Callback.AuthAccepted,
      this.fbAuthAccepted,
      this);

    this.fbAuth.bind(
      Denwen.Partials.Auth.Facebook.Callback.AuthRejected,
      this.fbAuthRejected,
      this);


    this.twAuth = new Denwen.Partials.Auth.Twitter();

    this.twAuth.bind(
      Denwen.Partials.Auth.Twitter.Callback.AuthAccepted,
      this.twAuthAccepted,
      this);

    this.twAuth.bind(
      Denwen.Partials.Auth.Twitter.Callback.AuthRejected,
      this.twAuthRejected,
      this);


    this.tumblrAuth = new Denwen.Partials.Auth.Tumblr();

    this.tumblrAuth.bind(
      Denwen.Partials.Auth.Tumblr.Callback.AuthAccepted,
      this.tumblrAuthAccepted,
      this);

    this.tumblrAuth.bind(
      Denwen.Partials.Auth.Tumblr.Callback.AuthRejected,
      this.tumblrAuthRejected,
      this);


    Denwen.NM.bind(
      Denwen.NotificationManager.Callback.FBTokenDead,
      this.fbTokenDead,
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

    if($(this.queryEl).is(":visible"))
      $(this.queryEl).phocus();
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

    this.trigger(
      Denwen.Partials.Purchases.Input.Callback.PurchaseInitiated);
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
  fbSwitchState: function() {
    return !$(this.fbSwitchEl).hasClass(this.switchOffClass);
  },

  // Returns the current state of the twitter photo toggle switch
  // on -> true & off -> false
  //
  twSwitchState: function() {
    return !$(this.twSwitchEl).hasClass(this.switchOffClass);
  },

  // Returns the current state of the tumblr photo toggle switch
  // on -> true & off -> false
  //
  tumblrSwitchState: function() {
    return !$(this.tumblrSwitchEl).hasClass(this.switchOffClass);
  },

  // Fired when the fb photo switch is toggled
  //
  fbSwitchToggled: function() {
    var setting = Denwen.H.currentUser.get('setting');

    if(!setting.get(Denwen.Settings.FbAuth)) { 
      $(this.fbSwitchEl).addClass(this.switchLoadingClass);
      this.fbAuth.showAuthDialog();
    }
    else if(!setting.get(Denwen.Settings.FbPublishPermissions)) { 
      $(this.fbSwitchEl).addClass(this.switchLoadingClass);
      this.fbSettings.showPermissionsDialog();
    }

    $(this.fbSwitchEl).toggleClass(this.switchOffClass);

    if(this.fbSwitchState())
      Denwen.Track.action("Purchase FB Photo On");
    else
      Denwen.Track.action("Purchase FB Photo Off");
  },

  // Fired when the tw photo switch is toggled
  //
  twSwitchToggled: function() {
    if(!Denwen.H.currentUser.get('setting').get(Denwen.Settings.TwAuth)) { 
      $(this.twSwitchEl).addClass(this.switchLoadingClass);
      this.twAuth.showAuthDialog();
    }

    $(this.twSwitchEl).toggleClass(this.switchOffClass);

    if(this.twSwitchState())
      Denwen.Track.action("Purchase TW Photo On");
    else
      Denwen.Track.action("Purchase TW Photo Off");
  },

  // Fired when the tumblr photo switch is toggled
  //
  tumblrSwitchToggled: function() {
    if(!Denwen.H.currentUser.get('setting').get(Denwen.Settings.TumblrAuth)) {
      $(this.tumblrSwitchEl).addClass(this.switchLoadingClass);
      this.tumblrAuth.showAuthDialog();
    }

    $(this.tumblrSwitchEl).toggleClass(this.switchOffClass);

    if(this.tumblrSwitchState())
      Denwen.Track.action("Purchase Tumblr Photo On");
    else
      Denwen.Track.action("Purchase Tumblr Photo Off");
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
    $(this.selectionEl).html(Denwen.JST['purchases/preview']({
      id: this.photoSelectionEl,
      imageURL: imageURL}));
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
    $(this.suggestionEl).val('');
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

      $(this.titleEl).addClass('error');
      Denwen.Track.purchaseValidationError('No Title');
    }
    else {
      $(this.titleEl).removeClass('error');
    }

    if(!this.isStoreUnknown() && ($(this.storeEl).val().length < 1 || 
          $(this.storeEl).val() == $(this.storeEl).attr('placeholder'))) {
      valid = false;

      $(this.storeEl).addClass('error');
      Denwen.Track.purchaseValidationError('No Store');
    }
    else {
      $(this.storeEl).removeClass('error');
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
    fields['post_to_timeline'] = this.fbSwitchState(); 
    fields['share_to_twitter'] = this.twSwitchState(); 
    fields['share_to_tumblr']  = this.tumblrSwitchState(); 

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
    $(this.fbSwitchEl).removeClass(this.switchLoadingClass);
  },

  // Fired when fb permissions are rejected
  //
  fbPermissionsRejected: function() {
    $(this.fbSwitchEl).toggleClass(this.switchOffClass);
    Denwen.Drawer.error("Please allow Facebook permissions for posting photos.");
  },


  //
  // Callbacks from fb token interface.
  //
  fbTokenDead: function() {
    $(this.fbSwitchEl).addClass(this.switchOffClass);
  },


  //
  // Callbacks from fb auth interface.
  //

  // Fired when fb auth is accepted 
  //
  fbAuthAccepted: function() {
    $(this.fbSwitchEl).removeClass(this.switchLoadingClass);
  },

  // Fired when fb auth is rejected
  //
  fbAuthRejected: function() {
    $(this.fbSwitchEl).removeClass(this.switchLoadingClass);
    $(this.fbSwitchEl).toggleClass(this.switchOffClass);
    Denwen.Drawer.error("Please allow access for posting to Facebook.");
  },


  //
  // Callbacks from tw auth interface.
  //

  // Fired when tw auth is accepted 
  //
  twAuthAccepted: function() {
    $(this.twSwitchEl).removeClass(this.switchLoadingClass);
  },

  // Fired when tw auth is rejected
  //
  twAuthRejected: function() {
    $(this.twSwitchEl).removeClass(this.switchLoadingClass);
    $(this.twSwitchEl).toggleClass(this.switchOffClass);
    Denwen.Drawer.error("Please allow Twitter Access for posting tweets.");
  },


  //
  // Callbacks from tumblr auth interface.
  //

  // Fired when tumblr auth is accepted 
  //
  tumblrAuthAccepted: function() {
    $(this.tumblrSwitchEl).removeClass(this.switchLoadingClass);
  },

  // Fired when tumblr auth is rejected
  //
  tumblrAuthRejected: function() {
    $(this.tumblrSwitchEl).removeClass(this.switchLoadingClass);
    $(this.tumblrSwitchEl).toggleClass(this.switchOffClass);
    Denwen.Drawer.error("Please allow access for posting to Tumblr.");
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

    purchase.set({'suggestion_id':$(this.suggestionEl).val()});

    if(this.resetOnCreation) {
      this.hidePurchaseImage();
      $(this.submitButtonEl).removeClass(this.postingClass);
      this.hideExtraSteps();
      this.resetForm();
      this.displayQueryBox();
      $(this.querySubBoxEl).hide();
      $(this.initPurchaseEl).show();
    }

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

    if($.support.placeholder && !attemptStoreSearch)
      title.length ? $(this.storeEl).focus() : $(this.titleEl).focus();
    else if(title.length)
      $(this.titleEl).focus();

    $(this.urlAlertBoxEl).hide();

    if(this.scrollOnSelection) 
      window.scrollTo(0,$(this.formEl).offset().top - 20);

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

    this.trigger(
      Denwen.Partials.Purchases.Input.Callback.ProductSelected,
      product);
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

    this.productSearch.initiateSearch(true);

    Denwen.Track.action("Product Image Broken");
  },

  // Fired when a product is searched from the ProductsImageView
  //
  productSearched: function(query,queryType) {
    this.searchesCount++;

    Denwen.Track.action("Product Search Started",{"Query Type" : queryType});

    if(queryType == Denwen.ProductQueryType.Text) {
      
      if(query.split(' ').length == 1 && !this.oneWordToolTipDone) {
        //Denwen.Drawer.info(CONFIG['one_word_query_msg'],0);
        this.oneWordToolTipDone = true;
      }
      else if(this.searchesCount == CONFIG['multi_query_threshold'] && 
                !this.urlToolTipDone) {
        //Denwen.Drawer.info(CONFIG['multi_query_msg'],0);
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
  },

  // Set suggestion id in the hidden field.
  //
  setSuggestion: function(suggestionID) {
    $(this.suggestionEl).val(suggestionID);
  },

  // Call phocus method on the primary query box.
  //
  queryPhocus: function() {
    $(this.queryEl).phocus();
  }

});

// Define callbacks.
//
Denwen.Partials.Purchases.Input.Callback = {
  PurchaseInitiated: "purchaseInitiated",
  ProductSelected: "productSelected",
  PurchaseCreated: "purchaseCreated",
  PurchaseCreationFailed: "purchaseCreationFailed"
};
