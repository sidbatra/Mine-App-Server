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
          with_focus        : /_comment$/i.test(this.source),
          el                : $('#comments_container')});

    new Denwen.Partials.Actionables.Actions({
          actionable_id       : this.product.get('id'),
          actionable_type     : 'product',
          actionable_user_id  : this.product.get('user_id'),
          el                  : $('#feedback')});

    new Denwen.Partials.Facebook.Base();

    if(helpers.isCurrentUser(this.product.get('user_id'))) {
      new Denwen.Partials.Products.Endorsement({
                  model   : this.product,
                  el      : $('#product_endorsement_box'),
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

    analytics.checkForEmailClickedEvent(this.source);
  }
});
