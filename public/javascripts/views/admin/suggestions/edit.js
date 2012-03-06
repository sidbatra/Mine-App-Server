// View for edit a suggestion
//
Denwen.Views.Admin.Suggestions.Edit = Backbone.View.extend({

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
