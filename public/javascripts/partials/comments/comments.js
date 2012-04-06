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
            success   : function() { self.render(); },
            error     : function() {}
          });
  },

  // Render the comments collection
  //
  render: function() {
    this.comments.each(function(comment){
      new Denwen.Partials.Comments.Comment({
            comment : comment,
            el      : '#product_comments_' + comment.get('product_id')});
    });
  }

});
