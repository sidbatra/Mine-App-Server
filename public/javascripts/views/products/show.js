// View js for Products/Show route
//
Denwen.Views.Products.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    var self  = this;

    this.product = new Denwen.Models.Product(this.options.productJSON);
    this.source  = this.options.source;
    this.friends = new Denwen.Collections.Users(this.options.friends);   

    this.owner   = this.product.get('user');

    this.interaction = this.friends.any(function(friend) {
                        return friend.get('id') == self.owner.get('id');
                       }) | Denwen.H.isCurrentUser(self.owner.get('id'));
    
    var productDisplay = new Denwen.Partials.Products.Display({
                              el          : $('#feed'),
                              model       : this.product,
                              interaction : this.interaction});

    if(this.product.get('fb_object_id') && this.interaction) { 
      this.likes = new Denwen.Partials.Likes.Likes();
      this.likes.fetch(this.product.get('id'));

      this.comments = new Denwen.Partials.Comments.Comments();
      this.comments.fetch(this.product.get('id'));
    }

    new Denwen.Partials.Facebook.Base();

    this.loadFacebookPlugs();

    this.setAnalytics();
  },

  // Load facebook code via partials
  //
  loadFacebookPlugs: function() {
    new Denwen.Partials.Facebook.Base();
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
