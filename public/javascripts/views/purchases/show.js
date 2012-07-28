// View js for Purchases/Show route
//
Denwen.Views.Purchases.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.source = this.options.source;

    if(Denwen.H.isLoggedIn()) {
      this.purchase = new Denwen.Models.Purchase(this.options.purchaseJSON);
      this.friends = new Denwen.Collections.Users(this.options.friends);

      this.owner = this.purchase.get('user');
      
      this.interaction = this.friends.any(function(friend) {
                          return friend.get('id') == self.owner.get('id');
                         }) | Denwen.H.isCurrentUser(self.owner.get('id')); 

      var purchaseDisplay = new Denwen.Partials.Purchases.Display({
                                el : $('#feed'),
                                interaction : this.interaction,
                                model : this.purchase});

      $('#purchase_thumb_' + this.purchase.get('id')).addClass('selected');
    }
    
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
