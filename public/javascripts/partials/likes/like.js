// Partial to display single facebook like 
//
Denwen.Partials.Likes.Like = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.like   = this.options.like; 
    this.onTop  = this.options.onTop;

    this.render();
  },

  // Render an individual like 
  //
  render: function() {
    if(!this.onTop)
      this.el.append(Denwen.JST['likes/like']({like:this.like}));
    else
      this.el.prepend(Denwen.JST['likes/like']({like:this.like}));
  }

});
