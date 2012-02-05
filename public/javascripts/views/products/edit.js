// View for editing an existing product
//
Denwen.Views.Products.Edit = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self         = this;
    this.product     = new Denwen.Models.Product(this.options.productJSON);
    this.category    = new Denwen.Models.Category(this.options.categoryJSON);
    this.input       = new Denwen.Partials.Products.Input({
                                            el:$('body'),mode:'edit'});
    this.source      = this.options.source;

    this.updateUI();

    this.setAnalytics();
  },

  // Update the UI based on the current product
  //
  updateUI: function() {

    this.input.displayProductImage(this.product.get('photo_url'));

    this.input.isStoreUnknownChanged();

    var endorsement = this.product.get('endorsement');

    if(endorsement.length) 
      this.input.displayEndorsement(true,endorsement);
  },

  // Fire various tracking events
  //
  setAnalytics: function() {

    analytics.productEditView(
        this.product.get('id'),
        this.source);
  }

});

