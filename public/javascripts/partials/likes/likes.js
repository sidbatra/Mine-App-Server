// Partial to load and display facebook likes 
// for a single purchase 
//
Denwen.Partials.Likes.Likes = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.likes = new Denwen.Collections.Likes();
  },

  // Fetch the likes for the given purchase ids
  //
  fetch: function(purchaseIds) {
    var self = this;

    this.likes.fetch({
            data      : {purchase_ids : purchaseIds},
            success   : function() { self.fetched(); },
            error     : function() {}});
  },

  // Fired when the like collection is fetched from the server 
  //
  fetched: function() {
    var self = this;

    this.likes.each(function(like){
      if(like.get('error')) {
        Denwen.NM.trigger(
          Denwen.NotificationManager.Callback.DisableLikes,
          like);
      }
      else {
        Denwen.NM.trigger(
          Denwen.NotificationManager.Callback.LikeFetched,
          like);
      }
    });

    Denwen.NM.trigger(Denwen.NotificationManager.Callback.LikesFetched);
  }

});
