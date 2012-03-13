// Load and display product suggestions
//
Denwen.Partials.Suggestions.Product = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self      = this;

    this.get();
  },

  // Fetches the suggestions
  //
  get: function() {
    var self    = this;
    this.suggestions  = new Denwen.Collections.Suggestions();

    this.suggestions.fetch({
            data:     {},
            success:  function(collection){self.render();},
            error:    function(collection,errors){}
            });
  },

  // Render the suggestions collection
  //
  render: function() {
    var self = this;
    
    if(!this.suggestions.isEmpty())
      $(this.el).show();

    $(this.el).html(
      Denwen.JST['suggestions/products']({
        suggestions : this.suggestions}));
  }

});
