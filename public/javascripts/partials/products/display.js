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

    this.interaction  = typeof this.options.interaction == 'undefined' ?
                          true : this.options.interaction;

    this.aggregateEl  = '#product_likes_' + this.model.get('id') + '_aggregate';
    this.likesBoxEl   = '#product_likes_box_' + this.model.get('id');
    this.likes        = new Denwen.Collections.Likes();

    this.render();

    if(Denwen.H.isLoggedIn() && 
        this.model.get('fb_object_id') && 
        this.interaction) { 
      this.newLike    = new Denwen.Partials.Likes.New(
                              {product_id:this.model.get('id')});

      this.newComment = new Denwen.Partials.Comments.New(
                              {product_id:this.model.get('id')});
    }

    Denwen.NM.bind(
                Denwen.NotificationManager.Callback.CommentFetched,
                this.commentFetched,
                this);

    Denwen.NM.bind(
                Denwen.NotificationManager.Callback.CommentCreated,
                this.commentCreated,
                this);

    Denwen.NM.bind(
                Denwen.NotificationManager.Callback.LikeFetched,
                this.likeFetched,
                this);

    Denwen.NM.bind(
                Denwen.NotificationManager.Callback.LikeCreated,
                this.likeCreated,
                this);

    Denwen.NM.bind(
                Denwen.NotificationManager.Callback.LikesFetched,
                this.likesFetched,
                this);
  },

  // Render the contents of the model.
  //
  render: function() {
    var html = Denwen.JST['products/display']({
                product     : this.model,
                interaction : this.interaction});

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

  // Render an individual like for the product
  //
  renderLike: function(like,onTop) {
    new Denwen.Partials.Likes.Like({
          like  : like,
          el    : $('#product_likes_' + like.get('product_id')),
          onTop : onTop});
  },

  // Render likes aggregation for the product
  //
  renderLikeAggregation: function() {
    var names     = [];
    var aggregate = "";

    this.likes.each(function(like){
      if(like.get('user_id') == Denwen.H.currentUser.get('fb_user_id')) {
        names.splice(0,0,'You');
      }
      else {
        names.push(like.get('name'));
      }
    });

    if(names.length == 1) {
      aggregate = names[0]
      aggregate += aggregate == 'You' ? ' like this' : ' likes this'; 
    }
    else if(names.length == 2) {
      aggregate = names.join(' and ') + ' like this';
    }
    else {
      aggregate = names.slice(0,names.length-1).join(', ') + ' and ' +  
                  names[names.length-1] + ' like this'; 
    }

    aggregate += ".";
    
    $(this.aggregateEl).html(aggregate);
  },

  // Fired when a comment is fetched for the product
  //
  commentFetched: function(comment) {
    if(this.model.get('id') == comment.get('product_id'))
      this.renderComment(comment);
  },

  // Fired when a comment is created for the product 
  //
  commentCreated: function(comment) {
    if(this.model.get('id') == comment.get('product_id'))
      this.renderComment(comment);
  },

  // Fired when a like is fetched for the product
  //
  likeFetched: function(like) {
    if(this.model.get('id') == like.get('product_id')) {

      if(Denwen.H.currentUser.get('fb_user_id') != like.get('user_id')) {
        this.renderLike(like,false);
      }
      else {
        this.renderLike(like,true);
        this.newLike.disable();  
      }
      
      this.likes.add(like);
    }
  },

  // Fired when a like is created for the product 
  //
  likeCreated: function(like) {
    if(this.model.get('id') == like.get('product_id')) {
      this.likes.add(like);

      this.renderLike(like,true);
      this.renderLikeAggregation();
      $(this.likesBoxEl).show(); 
    }
  },
  
  // Fired when all the likes associated with a product are fetched
  //
  likesFetched: function() {
    if(this.likes.length) {
      this.renderLikeAggregation();
      $(this.likesBoxEl).show(); 
    }
  }

});
