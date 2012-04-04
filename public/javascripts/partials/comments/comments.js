// Partial to load, display and create facebook comments 
// for products
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
            success   : function() { self.render(); },
            error     : function() {}
          });
  },

  // Render the comments collection
  //
  render: function() {
    var self = this;

    this.comments.each(function(comment){
      var commentsEl = '#comments_' + comment.get('product_id');
      $(commentsEl).append(Denwen.JST['comments/comment']({comment:comment}));
    });
  }

});
