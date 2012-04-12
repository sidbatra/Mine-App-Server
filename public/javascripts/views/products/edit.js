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
    this.input       = new Denwen.Partials.Products.Input({
                            el:$('body'),
                            mode:Denwen.ProductFormType.Edit});
    this.source      = this.options.source;

    this.updateUI();

    this.setAnalytics();
  },

  // Update the UI based on the current product
  //
  updateUI: function() {
    this.input.displayProductImage(this.product.get('giant_url'));

    this.input.isStoreUnknownChanged();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {

    Denwen.Track.productEditView(
        this.product.get('id'),
        this.source);
  }

});

