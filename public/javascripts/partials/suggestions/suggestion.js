Denwen.Partials.Suggestions.Suggestion = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.render();
  },

  // Override render method for displaying view
  //
  render: function() {
    this.el.prepend(Denwen.JST['suggestions/suggestion']({
      suggestion:this.model}));
  },
});

// Define callbacks.
//
Denwen.Partials.Suggestions.Suggestion.Callback = {
  Clicked : 'clicked'
}
