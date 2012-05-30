// Partial to display single facebook comment
//
Denwen.Partials.Comments.Comment = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.comment = this.options.comment; 

    if(!this.comment.get('error'))
      this.render();
    else
      Denwen.NM.trigger(
          Denwen.NotificationManager.Callback.DisableComments,
          this.comment);
  },

  // Render an individual comment
  //
  render: function() {
    this.el.append(Denwen.JST['comments/comment']({comment:this.comment}));
  }

});
