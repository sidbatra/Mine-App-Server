// View for fetching and displaying purchase suggestions.
//
Denwen.Partials.Feed.Suggestions = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.suggestionDelegate = this.options.suggestionDelegate;

    this.suggestions = new Denwen.Collections.Suggestions();
    this.fetch();
  },

  // Load and display suggestions.
  //
  fetch: function() {
    var self = this;

    this.suggestions.fetch({
      data: {},
      success: function(){self.suggestionsLoaded();},
      error: function(){self.suggestionsLoadingFailed();}});
  },

  // --
  // Callbacks from fetching suggestions
  // --

  // Render the loaded suggestions.
  //
  suggestionsLoaded: function() {
    var self = this;

    if(this.suggestions.every(function(suggestion){return suggestion.get('done');}))
      return;

	  this.suggestions.each(function(suggestion){
      var suggestion = new Denwen.Partials.Suggestions.Suggestion({
                            el:self.el,
                            model:suggestion});
      suggestion.bind(
        Denwen.Partials.Suggestions.Suggestion.Callback.Clicked,
        self.suggestionDelegate.suggestionClicked,
        self.suggestionDelegate);
    });

    this.el.fadeIn(250);
  },

  // Fail silently. 
  //
  suggestionsLoadingFailed: function() {
  }

});

 // Define callbacks.
//
 Denwen.Partials.Feed.Suggestions.Callback = { 
   Searched : 'searched' 
 } 
