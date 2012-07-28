// Partial for handling rendering and interactions of a purchase display.
//
Denwen.Partials.Purchases.Display = Backbone.View.extend({


  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.purchaseEl = '#purchase-' + this.model.get('id');
    this.panelEl = '#purchase_panel_' + this.model.get('id');
    this.likesEl = '#purchase_likes_' + this.model.get('id');
    this.likesBoxEl  = '#purchase_likes_box_' + this.model.get('id');
    this.aggregateEl = '#purchase_likes_' + this.model.get('id') + '_aggregate';
    this.aggregateTextEl = '#purchase_likes_' + this.model.get('id') + '_aggregate_text';
    this.commentsEl = '#purchase_comments_' + this.model.get('id');

    this.render();

    if(Denwen.H.isLoggedIn()) {
      this.newLike    = new Denwen.Partials.Likes.New({purchase:this.model});
      this.newComment = new Denwen.Partials.Comments.New({purchase:this.model});
    }

    Denwen.NM.bind(
                Denwen.NotificationManager.Callback.CommentCreated,
                this.commentCreated,
                this);

    Denwen.NM.bind(
                Denwen.NotificationManager.Callback.LikeCreated,
                this.likeCreated,
                this);
  },

  // Render the contents of the model.
  //
  render: function() {
    var html = Denwen.JST['purchases/display']({
                purchase    : this.model,
                interaction : this.interaction});

    if(this.model.get('fresh')) {
      this.el.prepend(html);

      if(Denwen.Device.get("is_phone"))
        $(this.purchaseEl).show();
      else
        $(this.purchaseEl).slideDown(750);

    }
    else
      this.el.append(html);
  },

  // Render an individual comment for the purchase
  //
  renderComment: function(comment) {
    new Denwen.Partials.Comments.Comment({
          comment : comment,
          el      : $(this.commentsEl)});
  },

  // Render an individual like for the purchase
  //
  renderLike: function(like,onTop) {
    new Denwen.Partials.Likes.Like({
          like  : like,
          el    : $(this.likesEl),
          onTop : onTop});
  },

  // Render likes aggregation for the purchase
  //
  renderLikeAggregation: function() {
    $(this.aggregateEl).html(this.likes.length);
    $(this.aggregateTextEl).html(this.likes.length == 1 ? 'like' : 'likes');
  },

  // Test if the comments have overflown the outer div and correct with
  // css scorlling magic if this have.
  //
  testOverflow: function() {
    if($(this.commentsEl).offset().top + $(this.commentsEl).height() +  75 > 
          $(this.purchaseEl).offset().top + $(this.purchaseEl).height())
      $(this.panelEl).addClass('overflowing');
  },

  // Fired when a comment is created for the purchase 
  //
  commentCreated: function(comment) {
    if(this.model.get('id') == comment.get('purchase_id')) {
      this.renderComment(comment);
      this.testOverflow();
    }
  },

  // Fired when a like is created for the purchase 
  //
  likeCreated: function(like) {
    if(this.model.get('id') == like.get('purchase_id')) {
      this.likes.add(like);

      this.renderLike(like,true);
      this.renderLikeAggregation();
      $(this.likesBoxEl).show(); 
    }
  }

});
