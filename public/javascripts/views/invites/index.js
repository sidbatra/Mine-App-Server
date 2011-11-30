// View js for the Invites/Index route
//
Denwen.Views.Invites.Index = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.currentUser = new Denwen.Models.User(this.options.currentUserJSON);

    new Denwen.Partials.Invites.FBFriends({
                        access_token : this.currentUser.get('access_token')});
                        
    // -----
    this.setAnalytics();
  },

  // Fire various tracking events 
  //
  setAnalytics: function() {

  }
  
});
