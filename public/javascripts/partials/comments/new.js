// Partial to create new comment 
//
Denwen.Partials.Comments.New = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self          = this;

    this.purchase     = this.options.purchase;
    this.inputEl      = '#purchase_comment_data_' + this.purchase.get('id');

    $(this.inputEl).keypress(function(e){self.commentKeystroke(e)});
    $(this.inputEl).placeholder();
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
    if(!$(this.inputEl).val())
      return;

    var self = this;
    var comment = new Denwen.Models.Comment({
                   purchase_id  : this.purchase.get('id'),
                   message      : $(this.inputEl).val()});

    this.render(comment);

    comment.save({},{
        success :  function(model) {self.created(model)},
        error   :  function(model,errors) {}
    });
  },

  // Render the comment created before sending the request
  // to our server
  //
  render: function(comment) {
    this.trigger(Denwen.Partials.Comments.New.Callback.CommentCreated,comment);

    $(this.inputEl).val('');
    $(this.inputEl).focus();
  },

  // Called when the comment is successfully created
  //
  created: function(comment) {
    if(!comment.get('id')) {
      Denwen.Drawer.error("Error posting comment. Try again in a second.");
    }
    else {
      Denwen.Track.action("Comment Created");
    }
  }

});

// Define callbacks.
//
Denwen.Partials.Comments.New.Callback = {
  CommentCreated: "commentCreated"
};
