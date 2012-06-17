Denwen.Partials.Suggestions.Suggestion = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.suggestionEl = "#suggestion_" + this.model.get('id');

    this.render();

    if(!this.model.get('done'))
      $(this.suggestionEl).click(function(){self.clicked()});
  },

  // Override render method for displaying view
  //
  render: function() {
    this.el.append(Denwen.JST['suggestions/suggestion']({
      suggestion:this.model}));
  },

  // Fired when suggestion is clicked.
  //
  clicked: function() {
    this.trigger(
      Denwen.Partials.Suggestions.Suggestion.Callback.Clicked,
      this.model);
  }
});

// Define callbacks.
//
Denwen.Partials.Suggestions.Suggestion.Callback = {
  Clicked : 'clicked'
}
