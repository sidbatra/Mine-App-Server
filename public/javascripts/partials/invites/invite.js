// Partial for creating invite records in the database
//
Denwen.Partials.Invites.Invite = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self            = this;
    this.FBUserIDs      = this.options.fb_user_ids;
    this.invites        = new Denwen.Collections.Invites();

    this.create();
  },

  // Create one or many invites by the current user 
  //
  create: function() {
    var self = this;

    this.FBUserIDs.forEach(function(FBUserID){
      self.invites.create({fb_user_id : FBUserID});
    });
  }

});
