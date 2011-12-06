// View for welcoming the user during onboarding
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
    analytics.welcomeView();

    if(this.source == 'login') {
      analytics.userCreated(); 
    }
  }

});
