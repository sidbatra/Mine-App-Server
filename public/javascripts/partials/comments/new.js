// Partial to create new comment 
//
Denwen.Partials.Comments.New = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self          = this;

    this.productID    = this.options.product_id;
    this.posting      = false;

    this.inputEl      = '#product_comment_data_' + this.productID;
    $(this.inputEl).keypress(function(e){self.commentKeystroke(e)});
  },

  // Fired after every keystroke on the comments data input.
  //
  commentKeystroke: function(e) {
    if(e.keyCode==13)
      this.post();
  },

  // Create a comment 
  //
  post: function() {
    if(this.posting)
      return;

    var self      = this;
    this.posting  = true;

    var comment   = new Denwen.Models.Comment({
                          product_id  : this.productID,
                          message     : $(this.inputEl).val()});

    comment.save({},{
        success :  function(model) {self.created(model)},
        error   :  function(model,errors) {}
    });
  },

  // Called when the comment is successfully created
  //
  created: function(comment) {
    this.posting = false;
    
    if(comment.get('id')) {
      new Denwen.Partials.Comments.Comment({
            comment : comment,
            el      : '#product_comments_' + this.productID}); 

      $(this.inputEl).val('');
      $(this.inputEl).focus();
    }
  }

});
