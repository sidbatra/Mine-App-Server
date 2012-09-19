// View for edit a theme
//
Denwen.Views.Admin.Themes.Edit = Backbone.View.extend({

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
