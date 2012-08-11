Denwen.Partials.Followings.Followings = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.followings = new Denwen.Collections.Followings();
    this.followings.fetch({
      success: function(){self.loaded()},
      error: function(){}});
  },

  // Following for the user are loaded.
  //
  loaded: function() {
    console.log(this.followings);
  }

});
