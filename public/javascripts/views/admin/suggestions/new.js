// View for creating a new suggestion
//
Denwen.Views.Admin.Suggestions.New = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    new Denwen.Partials.Admin.Suggestions.Input({
                    el:this.el,
          uploadConfig:this.options.uploadConfig});
  }
});
