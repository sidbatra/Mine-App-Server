// View js for Products/Show route
//
Denwen.Views.Products.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    var self  = this;

    this.product    = new Denwen.Models.Product(this.options.productJSON);
    this.source     = this.options.source;

    this.productImageEl = '#product_image';

    new Denwen.Partials.Facebook.Base();

    if(Denwen.H.isCurrentUser(this.product.get('user_id'))) {
      new Denwen.Partials.Products.Endorsement({
                  model   : this.product,
                  el      : $('#product_endorsement_box'),
                  source  : this.source});
    }

    $(this.productImageEl).click(function(){self.productImageClicked();});

    this.setAnalytics();
  },

  // User clicks the product image
  //
  productImageClicked: function() {
    analytics.productClicked();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    analytics.userLandsOn(this.product.uniqueKey());
    analytics.productProfileView(this.source,this.product.get('id'));

    if(this.source == 'product_updated')
      analytics.productUpdated(this.product.get('id'));

    analytics.checkForEmailClickedEvent(this.source);
  }
});
