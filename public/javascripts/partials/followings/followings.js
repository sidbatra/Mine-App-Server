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
    this.followings.each(function(following){
      Denwen.NM.trigger(
        Denwen.NotificationManager.Callback.FollowingLoaded,
        following);
    });

    Denwen.NM.trigger(
      Denwen.NotificationManager.Callback.FollowingLoadingComplete);
  }

});
