// Render a single comment
//
Denwen.CommentView = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.render();
  },

  // Render the comment
  //
  render: function() {
    $(this.el).prepend(Denwen.JST['comments/comment']({comment:this.model}));
  }

});
