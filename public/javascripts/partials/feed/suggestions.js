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

  // Render the loaded suggestions.
  //
  suggestionsLoaded: function() {
    var self = this;

	  this.suggestions.each(function(suggestion){
      var suggestion = new Denwen.Partials.Suggestions.Suggestion({
                            el:self.el,
                            model:suggestion});
    });
  },

  // Fail silently. 
  //
  suggestionsLoadingFailed: function() {
  }

});
