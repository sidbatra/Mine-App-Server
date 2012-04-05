// View js for Products/Show route
//
Denwen.Views.Products.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    var self  = this;

    this.product    = new Denwen.Models.Product(this.options.productJSON);
    this.source     = this.options.source;

    this.comments   = new Denwen.Partials.Comments.Comments();
    this.comments.fetch(this.product.get('id'));

    new Denwen.Partials.Comments.New({product_id:this.product.get('id')});

    this.likes = new Denwen.Partials.Likes.Likes();
    this.likes.fetch(this.product.get('id'));

    new Denwen.Partials.Facebook.Base();

    if(Denwen.H.isCurrentUser(this.product.get('user_id'))) {
      new Denwen.Partials.Products.Endorsement({
                  model   : this.product,
                  el      : $('#product_endorsement_box'),
                  source  : this.source});
    }

    this.productImageEl = '#product_image';

    $(this.productImageEl).click(function(){self.productImageClicked();});

    this.setAnalytics();
  },

  // User clicks the product image
  //
  productImageClicked: function() {
    Denwen.Track.productClicked();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    Denwen.Track.userLandsOn(this.product.uniqueKey());
    Denwen.Track.productProfileView(this.source,this.product.get('id'));

    if(this.source == 'product_updated')
      Denwen.Track.productUpdated(this.product.get('id'));

    Denwen.Track.checkForEmailClickedEvent(this.source);
  }
});
