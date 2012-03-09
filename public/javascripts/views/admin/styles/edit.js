// View for edit a style
//
Denwen.Views.Admin.Styles.Edit = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    new Denwen.Partials.Admin.Styles.Input({
                    el:this.el,
          uploadConfig:this.options.uploadConfig});
  }
});
