// View for displaying the site introduction during onboarding
//
Denwen.Views.Welcome.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.source = this.options.source;

    // -----
    this.setAnalytics();
  },

  // Fire tracking events
  //
  setAnalytics: function() {

    analytics.fbConnectAccepted();
    analytics.welcomeView();

    if(this.source == 'login') {
      analytics.userCreated(); 
    }
  }

});
