// Partial for batch insertion of invites in the database
//
Denwen.Partials.Invites.BatchInvite = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self            = this;
    this.FBUserIDs      = this.options.fb_user_ids;
    this.batchInvite    = new Denwen.Models.BatchInvite();

    this.create();
  },

  // Create batch invites by the current user 
  //
  create: function() {
    this.batchInvite.save({fb_user_ids : this.FBUserIDs});
  }

});
