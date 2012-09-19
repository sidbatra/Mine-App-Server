// View for creating a new theme
//
Denwen.Views.Admin.Themes.New = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    new Denwen.Partials.Admin.Themes.Input({
                    el:this.el,
          uploadConfig:this.options.uploadConfig});
  }
});
