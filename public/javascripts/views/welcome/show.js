// View for displaying the site introduction during onboarding
//
Denwen.Views.Welcome.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.currentUser = new Denwen.Models.User(this.options.currentUser);

    this.setAnalytics();
  },

  // Fire tracking events
  //
  setAnalytics: function() {
    Denwen.Track.welcomeView();
    Denwen.Track.userCreated(); 
    Denwen.Track.identifyUser(
      this.currentUser.get('email'),
      this.currentUser.get('age'),
      this.currentUser.get('gender'));
  }

});
