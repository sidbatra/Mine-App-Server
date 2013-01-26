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
    var self = this;
    this.interaction = this.options.interaction;

    if (typeof this.interaction  === "undefined")
      this.interaction = Denwen.H.isLoggedIn();


    this.full = this.options.full;

    if (typeof this.full  === "undefined")
      this.full = false;


    this.crossButton = this.options.crossButton;

    if (typeof this.crossButton  === "undefined")
      this.crossButton = false;


    this.purchaseEl = '#purchase-' + (this.full ? 'full-' : '') + this.model.get('id');
    this.purchaseModalEl = '#item-modal-' + this.model.get('id');

    this.render();


    if(Denwen.H.isLoggedIn()) {
      this.crossEl.click(function(){self.crossButtonClicked();});

      this.newLike = new Denwen.Partials.Likes.New({
                            purchase:this.model,
                            el: $(this.purchaseEl)});

      this.newComment = new Denwen.Partials.Comments.New({
                              purchase:this.model,
                              el: $(this.purchaseEl)});

      Denwen.NM.bind(
        Denwen.NotificationManager.Callback.LikeCreated,
        this.likeCreated,
        this);

      this.newComment.bind(
        Denwen.Partials.Comments.New.Callback.CommentCreated,
        this.commentCreated,
        this);

      this.model.get('likes').each(function(like){
        if(Denwen.H.isCurrentUser(like.get('user').get('id')))
          self.newLike.disable();
      });
    }

    
    this.photoEl.click(function(){self.photoClicked();});
    this.titleEl.click(function(){self.titleClicked();});
    this.commentInitEl.click(function(){self.commentInitClicked();});
  },

  // Render the contents of the model.
  //
  render: function() {
    var html = Denwen.JST['purchases/display']({
                purchase    : this.model,
                interaction : this.interaction,
                crossButton : this.crossButton,
                full       : this.full});

    if(this.model.get('fresh')) {
      this.el.prepend(html);

      if(Denwen.Device.get("is_phone"))
        $(this.purchaseEl).show();
      else
        $(this.purchaseEl).slideDown(750);

    }
    else
      this.el.append(html);


    this.photoEl = $(this.purchaseEl).find(".sel-purchase-photo");
    this.titleEl = $(this.purchaseEl).find(".sel-purchase-title");
    this.crossEl = $(this.purchaseEl).find(".sel-purchase-cross");
    //this.panelEl = $(this.purchaseEl).find(".sel-purchase-panel");
    this.likesEl = $(this.purchaseEl).find(".sel-purchase-likes");
    this.likesBoxEl  = $(this.purchaseEl).find(".sel-purchase-likes-box");
    this.aggregateEl = $(this.purchaseEl).find(".sel-purchase-likes-agg"); 
    this.aggregateTextEl = $(this.purchaseEl).find(".sel-purchase-likes-agg-text");
    this.commentInitEl = $(this.purchaseEl).find(".sel-purchase-comment-init");
    this.commentsEl = $(this.purchaseEl).find(".sel-purchase-comments");
    this.commentsBoxEl = $(this.purchaseEl).find(".sel-purchase-comments-box"); 



    
    var self = this;

    // Render likes
    if(!this.model.get('likes').isEmpty()) {

      this.likesBoxEl.show();

      this.model.get('likes').each(function(like){
        self.renderLike(like,false);
      });

      self.renderLikeAggregation();
    }

    // Render comments
    this.model.get('comments').each(function(comment){
      self.renderComment(comment);
    });

    if(!this.interaction && this.model.get('comments').isEmpty()) {
      this.commentsBoxEl.hide();
    }

    this.likesBoxEl.find("a[rel='tooltip']").tooltip();

    this.testOverflow();
  },

  // Render an individual comment for the purchase
  //
  renderComment: function(comment) {
    new Denwen.Partials.Comments.Comment({
          comment : comment,
          el      : this.commentsEl});
  },

  // Render an individual like for the purchase
  //
  renderLike: function(like,onTop) {
    new Denwen.Partials.Likes.Like({
          like  : like,
          el    : this.likesEl,
          onTop : onTop});
  },

  renderModal: function() {
    $(this.purchaseModalEl).html('');

    var purchaseDisplay = new Denwen.Partials.Purchases.Display({
                              el: $(this.purchaseModalEl),
                              model: this.model,
                              interaction: this.interactive,
                              full: true});
  },

  // Render likes aggregation for the purchase
  //
  renderLikeAggregation: function() {
    this.aggregateEl.html(this.model.get('likes').length);
    this.aggregateTextEl.html(this.model.get('likes').length == 1 ? 'like' : 'likes');
  },

  // Test if the comments have overflown the outer div and correct with
  // css scorlling magic if this have.
  //
  testOverflow: function() {
    //if(this.commentsEl.offset().top + this.commentsEl.height() +  75 > 
    //      $(this.purchaseEl).offset().top + $(this.purchaseEl).height())
    //  $(this.panelEl).addClass('overflowing');
  },

  // Fired when a comment is created for the purchase 
  //
  commentCreated: function(comment) {
    comment.set({user: Denwen.H.currentUser});
    this.renderComment(comment);
    this.testOverflow();
  },

  // Fired when a like is created for the purchase 
  //
  likeCreated: function(like) {
    if(like.get('purchase_id') != this.model.get('id'))
      return;


    like.set({user: Denwen.H.currentUser});

    if(!this.model.get('likes').getByCid(like.cid))
      this.model.get('likes').add(like);

    this.renderLike(like,true);
    this.renderLikeAggregation();

    this.likesBoxEl.show(); 

    this.newLike.disable();
  },

  crossButtonClicked: function() {
    $(this.purchaseEl).fadeOut(50);

    Denwen.NM.trigger(
      Denwen.NotificationManager.Callback.PurchaseCrossClicked,
      this.model);
  },

  // Purchase photo is clicked.
  //
  photoClicked: function() {

    if(this.full) {
      window.open(this.model.get('source_url'), '_blank');
      window.focus();
      Denwen.Track.purchaseURLVisit('photo');
    }
    else {
      this.renderModal();
    }

  },

  // Purchase title is clicked.
  //
  titleClicked: function() {
    Denwen.Track.purchaseURLVisit('title');
  },

  commentInitClicked: function() {
    this.renderModal();
  }

});
