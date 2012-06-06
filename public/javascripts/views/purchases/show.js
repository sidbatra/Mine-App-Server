// View js for Purchases/Show route
//
Denwen.Views.Purchases.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    var self  = this;

    this.purchase = new Denwen.Models.Purchase(this.options.purchaseJSON);
    this.panel = this.options.panel;
    this.source  = this.options.source;

    var purchaseDisplay = new Denwen.Partials.Purchases.Display({
                              el : $('#feed'),
                              model : this.purchase});

    if(Denwen.H.isLoggedIn()) {
      this.likes = new Denwen.Partials.Likes.Likes();
      this.likes.fetch(this.purchase.get('id'));

      this.comments = new Denwen.Partials.Comments.Comments();
      this.comments.fetch(this.purchase.get('id'));

      $('#purchase_thumb_' + this.purchase.get('id')).addClass('selected');
    }
    else {
      $('#purchase_panel_content_' + this.purchase.get('id')).html(this.panel);
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

  // Fire various tracking events
  //
  setAnalytics: function() {
    Denwen.Track.action("Purchase View",{"Source" : this.source});

    if(!Denwen.H.isLoggedIn())
      Denwen.Track.action("Purchase View Logged Out");

    Denwen.Track.isEmailClicked(this.source);
    Denwen.Track.origin("purchase");
  }
});
