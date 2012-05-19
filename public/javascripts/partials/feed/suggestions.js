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

	  this.suggestions.each(function(suggestion){
      var suggestion = new Denwen.Partials.Suggestions.Suggestion({
                            el:self.el,
                            model:suggestion});
      suggestion.bind(
        Denwen.Partials.Suggestions.Suggestion.Callback.Searched,
        self.suggestionSearched,
        self);
    });
  },

  // Fail silently. 
  //
  suggestionsLoadingFailed: function() {
  },


  // --
  // Callbacks from Suggestions.Suggestion partials.
  // --

  // Fired when a suggestion is searched.
  //
  suggestionSearched: function(query,suggestion) {
    this.trigger(
      Denwen.Partials.Feed.Suggestions.Callback.Searched,
      query,
      suggestion.get('id'));
  }

});

 // Define callbacks.
//
 Denwen.Partials.Feed.Suggestions.Callback = { 
   Searched : 'searched' 
 } 
