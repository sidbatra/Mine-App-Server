// Input box for creating comments
//
Denwen.CommentInputView = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
    "click #comment_post": "post"
  },

  // Constructor logic
  //
  initialize: function() {
    this.posting    = false;
    this.inputEl    = '#comment_data';
    this.commentsEl = '#comments';

    make_conditional_field(
      this.inputEl,
      $(this.inputEl).val(),
      $(this.inputEl).css('color'),
      '#333333');
  },

  // Called when the comment is successfully created
  //
  created: function(comment) {
    this.posting = false;

    $(this.commentsEl).prepend(comment.get('html'));
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

    this.model.clone().save(
      {'data':$(this.inputEl).val()},
      { 
        success:  function(model) {self.created(model)},
        error:    function(model,errors) {},
      });

    analytics.commentCreated();
  },

});
