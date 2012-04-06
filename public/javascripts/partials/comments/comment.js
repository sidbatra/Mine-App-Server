// Partial to display single facebook comment
//
Denwen.Partials.Comments.Comment = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.comment = this.options.comment; 
    this.render();
  },

  // Render an individual comment
  //
  render: function() {
    this.el.append(Denwen.JST['comments/comment']({comment:this.comment}));
  }

});
