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
    this.storeEl              = $('#product_store_name_' + this.productID);
    this.storeBoxEl           = $('#product_store_box_' + this.productID);
    this.isStoreUnknownEl     = $('#product_is_store_unknown_'+ this.productID);

    this.isStoreUnknownEl.change(function(){self.isStoreUnknownChanged();});

    make_conditional_field(this.storeEl);
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
                  is_store_unknown:this.isStoreUnknown() ? '1' : '0',
                  source_product_id:this.productID,
                  clone:true};

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

    if(!this.isStoreUnknown() && 
          (this.storeEl.val().length < 1 || 
            this.storeEl.val() == this.storeEl.attr('data-placeholder'))) {
      valid = false;

      $(this.storeBoxEl).addClass('error');
      analytics.productException('No Store',mode);
    }
    else {
      $(this.storeBoxEl).removeClass('error');
    }

    return valid;
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

      this.storeEl.removeClass('incomplete');
    }
    else {
      this.storeBoxEl.removeClass('inactive');
      this.storeEl.removeAttr('disabled');
    }
  }

});
