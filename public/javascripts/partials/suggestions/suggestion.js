Denwen.Partials.Suggestions.Suggestion = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.suggestionEl = "#suggestion-" + this.model.get('id');
    this.inputEl = "#suggestion-input-" + this.model.get('id');
    this.submitEl = "#suggestion-button-" + this.model.get('id');

    this.render();

    $(this.inputEl).keypress(function(e){self.inputKeypress(e)});
    $(this.submitEl).click(function(){self.submitClicked()});
  },

  // Override render method for displaying view
  //
  render: function() {
    this.el.prepend(Denwen.JST['suggestions/suggestion']({
      suggestion:this.model}));
  },

  // Fired when a key is pressed on the input.
  //
  inputKeypress: function(e) {
    if(e.which == 13)
      this.triggerSearchedCallback();
  },

  // Fired when the submit button is pressed.
  //
  submitClicked: function() {
    this.triggerSearchedCallback();
  },
  
  // Trigger a callback when the user initates
  // a search via a suggestion.
  //
  triggerSearchedCallback: function() {

    if(!$(this.inputEl).val().length)
      return;

    $(this.suggestionEl).fadeOut(300);

    this.trigger(
      Denwen.Partials.Suggestions.Suggestion.Callback.Searched,
      $(this.inputEl).val(),
      this.model);
  }
});

// Define callbacks.
//
Denwen.Partials.Suggestions.Suggestion.Callback = {
  Searched : 'searched'
}
