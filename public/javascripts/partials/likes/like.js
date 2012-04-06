// Partial to display single facebook like 
//
Denwen.Partials.Likes.Like = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.like = this.options.like; 
    this.aggregateEl = '#' + this.el.attr('id') + '_aggregate';
    this.render();
  },

  // Render an individual like 
  //
  render: function() {
    this.el.append(Denwen.JST['likes/like']({like:this.like}));

    if(this.like.get('aggregate'))
      $(this.aggregateEl).html(this.like.get('aggregate') + ' like this');
  }

});
