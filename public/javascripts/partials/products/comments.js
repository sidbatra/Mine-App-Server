// Partial to load and display comments for a product
//
Denwen.Partials.Products.Comments = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
    "click #comment_post"  : "post"
  },

  // Constructor logic
  //
  initialize: function() {
    var self                = this;

    this.posting            = false;
    this.productID          = this.options.product_id;

    this.inputEl            = '#comment_data';
    this.commentsEl         = '#comments';
    this.commentPlaceholder = $(this.inputEl).val();

    this.comments           = new Denwen.Collections.Comments();
    this.comments.fetch({
            data      : {product_id: this.options.product_id},
            success   : function() { self.render(); },
            error     : function() {}
          });

    make_conditional_field(
      this.inputEl,
      $(this.inputEl).val(),
      $(this.inputEl).css('color'),
      '#333333');
  },

  // Render the comments collection
  //
  render: function() {
    var self = this;

    this.comments.each(function(comment){
      $(self.commentsEl).prepend(Denwen.JST['comments/comment']({
                                    comment:comment}));
    });
  },

  // Creates a comment
  //
  post: function() {
    if(this.posting)
      return;

    var self      = this;
    this.posting  = true;

    var comment   = new Denwen.Models.Comment({
                          data        : $(this.inputEl).val(),
                          product_id  : this.productID,
                          defaultData : this.commentPlaceholder});

    this.comments.add(comment);

    comment.save({
          data    :  $(this.inputEl).val()}, { 
          success :  function(model) {self.created(model)},
          error   :  function(model,errors) {}
      });

    analytics.commentCreated();
  },

  // Called when the comment is successfully created
  //
  created: function(comment) {
    this.posting = false;

    $(this.commentsEl).prepend(Denwen.JST['comments/comment']({
                                  comment:comment}));

    $(this.inputEl).val('');
    $(this.inputEl).focus();
  }

});
