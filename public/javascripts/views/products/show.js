// View js for Products/Show route
//
Denwen.Views.Products.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.product    = new Denwen.Models.Product(this.options.productJSON);
    this.source     = this.options.source;

    new Denwen.Partials.Products.Comments({
          product_id  : this.product.get('id'),
          el          : $('#comments_container')});

    new Denwen.Partials.Facebook.Base();

    if(helpers.isCurrentUser(this.product.get('user_id'))) {
      new Denwen.ProductEndorsementView({
                  model   : this.product,
                  el      : $('#right_extras'),
                  source  : this.source});
    }

    this.setAnalytics();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    analytics.userLandsOn(this.product.uniqueKey());
    analytics.productProfileView(this.source,this.product.get('id'));
  }
});
