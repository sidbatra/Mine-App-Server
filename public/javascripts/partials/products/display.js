// Partial for handling rendering and interactions of a product display.
//
Denwen.Partials.Products.Display = Backbone.View.extend({


  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.render();

    if(Denwen.H.isLoggedIn() && this.model.get('fb_object_id')) {
      new Denwen.Partials.Likes.New({product_id:this.model.get('id')});
      new Denwen.Partials.Comments.New({product_id:this.model.get('id')});
    }

    Denwen.NM.bind(
                Denwen.NotificationManager.Callback.CommentFetched,
                this.commentFetched,
                this);

    Denwen.NM.bind(
                Denwen.NotificationManager.Callback.CommentCreated,
                this.commentCreated,
                this);
  },

  // Render the contents of the model.
  //
  render: function() {
    var html = Denwen.JST['products/display']({product: this.model});

    if(this.model.get('fresh'))
      this.el.prepend(html);
    else
      this.el.append(html);
  },

  // Render an individual comment for the product
  //
  renderComment: function(comment) {
    new Denwen.Partials.Comments.Comment({
          comment : comment,
          el      : $('#product_comments_' + comment.get('product_id'))});
  },

  // Fired when a single comment has been fetched for the product
  //
  commentFetched: function(comment) {
    if(this.model.get('id') == comment.get('product_id'))
      this.renderComment(comment);
  },

  // Fired when a comment has been created for the product 
  //
  commentCreated: function(comment) {
    if(this.model.get('id') == comment.get('product_id'))
      this.renderComment(comment);
  }

});
