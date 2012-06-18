Denwen.Partials.Suggestions.Suggestion = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.activeClass = 'active';

    this.suggestionEl = "#suggestion_" + this.model.get('id');

    this.render();

    if(!this.model.get('done')) {
      $(this.suggestionEl).click(function(){self.clicked()});

      Denwen.NM.bind(
        Denwen.NotificationManager.Callback.SuggestionClicked,
        this.suggestionClicked,
        this);

      Denwen.NM.bind(
        Denwen.NotificationManager.Callback.SuggestionFinished,
        this.suggestionFinished,
        this);
    }
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
     $(this.suggestionEl).addClass(this.activeClass);

    this.trigger(
      Denwen.Partials.Suggestions.Suggestion.Callback.Clicked,
      this.model);
  },

  // --
  // Callbacks from NotificationManager
  // --
  
  suggestionClicked: function(suggestionID) {
    if(this.model.get('id') != suggestionID) {
      $(this.suggestionEl).removeClass(this.activeClass);
    }
  },

  suggestionFinished: function(suggestionID) {
    if(this.model.get('id') == suggestionID) {
      $(this.suggestionEl).removeClass(this.activeClass);
      $(this.suggestionEl).addClass('done');
      $(this.suggestionEl).unbind('click');
    }
  }

});
// Define callbacks.
//
Denwen.Partials.Suggestions.Suggestion.Callback = {
  Clicked : 'clicked'
}
