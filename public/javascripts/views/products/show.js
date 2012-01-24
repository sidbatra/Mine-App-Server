// View js for Products/Show route
//
Denwen.Views.Products.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.product    = new Denwen.Models.Product(this.options.productJSON);
    this.source     = this.options.source;

    new Denwen.Partials.Commentables.Comments({
          commentable_id    : this.product.get('id'),
          commentable_type  : 'product',
          el                : $('#comments_container')});

    new Denwen.Partials.Products.Actions({
          product_id      : this.product.get('id'),
          product_user_id : this.product.get('user_id'),
          el              : $('#feedback')});

    new Denwen.Partials.Facebook.Base();

    if(helpers.isCurrentUser(this.product.get('user_id'))) {
      new Denwen.Partials.Products.Endorsement({
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

    if(this.source == 'product_updated')
      analytics.productUpdated(this.product.get('id'));

    if(this.source.slice(0,6) == 'email_')
      analytics.emailClicked(this.source.slice(6,this.source.length));
  }
});
