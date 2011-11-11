// View to load and display comments for a product
//
Denwen.ProductCommentsView = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
    "click #comment_post"  : "post",
    "focus #comment_data"  : "commentFocus"
  },

  initialize: function() {
    var self        = this;
    this.posting    = false;
    this.inputEl    = '#comment_data';
    this.commentsEl = '#comments';
    this.comment    = new Denwen.Comment({
                            defaultData:$(this.inputEl).val(),
                            product_id:this.options.product_id});
    this.comments   = new Denwen.Comments();

    this.comments.fetch(
          {
            data      : {product_id: this.options.product_id},
            success   : function() { self.commentsLoaded(); },
            error     : function() {}
          });

    make_conditional_field(
      this.inputEl,
      $(this.inputEl).val(),
      $(this.inputEl).css('color'),
      '#333333');
  },

  // Fired when the comments are successfully loaded
  //
  commentsLoaded: function() {
    var self = this;

    this.comments.each(function(comment){
      $(self.commentsEl).append(JST['comments/comment']({comment:comment}));
    });
  },

  // Called when the comment is successfully created
  //
  created: function(comment) {
    this.posting = false;

    $(this.commentsEl).prepend(JST['comments/comment']({comment:comment}));
    $(this.inputEl).val('');
    $(this.inputEl).focus();
  },

  // Creates a comment
  //
  post: function() {
    if(this.posting)
      return;

    var self      = this;
    this.posting  = true;

    this.comment.clone().save(
      {'data':$(this.inputEl).val()},
      { 
        success:  function(model) {self.created(model)},
        error:    function(model,errors) {}
      });

    analytics.commentCreated();
  },

  // Fired when user focuses on comment box
  //
  commentFocus: function() {
  }

});
