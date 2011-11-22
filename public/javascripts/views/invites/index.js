// View for inviting people to the website 
//
Denwen.Views.Invites.= Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self        = this;

    this.friends    = new Denwen.Collections.Friends(this.options.friendsJSON);
    this.search     = new Denwen.Partials.Invites.Facebook();
    this.source     = this.options.source;

    this.setAnalytics();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
  }

});

