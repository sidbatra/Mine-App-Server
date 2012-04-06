// Partial to load and display all facebook comments 
// for a single product
//
Denwen.Partials.Comments.Comments = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.comments = new Denwen.Collections.Comments();
  },

  // Fetch the commments for the given product ids
  //
  fetch: function(productIds) {
    var self = this;

    this.comments.fetch({
            data      : {product_ids : productIds},
            success   : function() { self.fetched(); },
            error     : function() {}
          });
  },

  // Called when the comments collection had been fetched
  // from the server
  //
  fetched: function() {
    this.comments.each(function(comment){
      Denwen.NM.trigger(
          Denwen.NotificationManager.Callback.CommentFetched,
          comment);
    });
  }

});
