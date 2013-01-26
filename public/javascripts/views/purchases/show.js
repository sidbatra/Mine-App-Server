// View js for Purchases/Show route
//
Denwen.Views.Purchases.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.source = this.options.source;

    this.purchase = new Denwen.Models.Purchase(this.options.purchaseJSON);
    this.owner = this.purchase.get('user');
    
    var purchaseDisplay = new Denwen.Partials.Purchases.Display({
                              el : $('#feed'),
                              model : this.purchase,
                              full : true});

    $('#purchase_thumb_' + this.purchase.get('id')).addClass('selected');


    // -----
    if(!Denwen.H.isLoggedIn()) {
      new Denwen.Partials.Users.Box({
        el: $('#user_box'),
        user: this.owner
      });
    }
    
    this.loadFacebookPlugs();

    this.setAnalytics();

    new Denwen.Partials.Pinterest.Base();
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
