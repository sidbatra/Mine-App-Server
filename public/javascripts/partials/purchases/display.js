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

      this.newLike.bind(
        Denwen.Partials.Likes.New.Callback.LikeCreated,
        this.likeCreated,
        this);

      this.newComment.bind(
        Denwen.Partials.Comments.New.Callback.CommentCreated,
        this.commentCreated,
        this);

    }
  },

  // Render the contents of the model.
  //
  render: function() {
    var html = Denwen.JST['purchases/display']({
                purchase    : this.model,
                interaction : Denwen.H.isLoggedIn()});

    if(this.model.get('fresh')) {
      this.el.prepend(html);

      if(Denwen.Device.get("is_phone"))
        $(this.purchaseEl).show();
      else
        $(this.purchaseEl).slideDown(750);

    }
    else
      this.el.append(html);

    
    var self = this;

    // Render likes
    if(!this.model.get('likes').isEmpty()) {

      $(this.likesBoxEl).show();

      this.model.get('likes').each(function(like){
        self.renderLike(like,false);
      });

      self.renderLikeAggregation();
    }

    // Render comments
    this.model.get('comments').each(function(comment){
      self.renderComment(comment);
    });
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
    $(this.aggregateEl).html(this.model.get('likes').length);
    $(this.aggregateTextEl).html(this.model.get('likes').length == 1 ? 'like' : 'likes');
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
    comment.set({user: Denwen.H.currentUser});
    this.renderComment(comment);
    //this.testOverflow();
  },

  // Fired when a like is created for the purchase 
  //
  likeCreated: function(like) {
    like.set({user: Denwen.H.currentUser});

    this.model.get('likes').add(like);

    this.renderLike(like,true);
    this.renderLikeAggregation();

    $(this.likesBoxEl).show(); 
  }

});
