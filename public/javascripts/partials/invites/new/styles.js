// Partial for choosing styles
//
Denwen.Partials.Invites.New.Styles = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.inviteSuccessEl = "#invite_success";
  },

  // Fired just before the sub view comes into focus
  //
  display: function(success) {
    if(success) {
      var self = this;
      $(this.inviteSuccessEl).fadeIn();
      setTimeout(function(){$(self.inviteSuccessEl).fadeOut();},5000);
    }
  }

});
