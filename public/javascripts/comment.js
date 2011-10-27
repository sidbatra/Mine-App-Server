var Comment = Backbone.Model.extend({

  urlRoot: '/comments',

  initialize: function() {
  },

  validate: function(attrs) {
    if(attrs.data.length < 1 || attrs.data == this.get('defaultData')) 
      return "No comment entered";
  }

});


var CommentInputView = Backbone.View.extend({

  events: {
    "click #comment_post": "post"
  },

  initialize: function() {
    this.inputEl    = '#comment_data';
    this.commentsEl = '#comments';

    make_conditional_field(
      this.inputEl,
      $(this.inputEl).val(),
      $(this.inputEl).css('color'),
      '#333333');
  },

  created: function(comment) {
    $(this.commentsEl).prepend(comment.get('html'));
    $(this.inputEl).val('');
    $(this.inputEl).focus();
  },

  post: function() {

    var self = this;

    this.model.clone().save(
      {'data':$(this.inputEl).val()},
      { 
        success: function(model) {self.created(model)},
        error : function(model,errors) {},
      });

    mpq.track("Comment Created");

  },

});
