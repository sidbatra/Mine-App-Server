// View js for Purchases/Show route
//
Denwen.Views.Purchases.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    var self  = this;

    this.purchase = new Denwen.Models.Purchase(this.options.purchaseJSON);
    this.source  = this.options.source;
    this.friends = new Denwen.Collections.Users(this.options.friends);   

    this.owner   = this.purchase.get('user');

    this.interaction = this.friends.any(function(friend) {
                        return friend.get('id') == self.owner.get('id');
                       }) | Denwen.H.isCurrentUser(self.owner.get('id'));
    
    var purchaseDisplay = new Denwen.Partials.Purchases.Display({
                              el          : $('#feed'),
                              model       : this.purchase,
                              interaction : this.interaction,
                              extraMargin : true});

    if(this.purchase.get('fb_object_id')) { 

      if(this.interaction || !Denwen.H.isLoggedIn()) {
        this.likes = new Denwen.Partials.Likes.Likes();
        this.likes.fetch(this.purchase.get('id'));
      }

      if(this.interaction) {
        this.comments = new Denwen.Partials.Comments.Comments();
        this.comments.fetch(this.purchase.get('id'));
      }
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
    Denwen.Track.isEmailClicked(this.source);
  }
});
