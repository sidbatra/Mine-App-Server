// Partial to display single facebook like 
//
Denwen.Partials.Likes.Like = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.like = this.options.like; 
    this.render();
  },

  // Render an individual like 
  //
  render: function() {
      $(this.el).append(Denwen.JST['likes/like']({like:this.like}));
  }

});
