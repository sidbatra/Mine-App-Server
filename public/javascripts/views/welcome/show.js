// View for displaying the site introduction during onboarding
//
Denwen.Views.Welcome.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.qEls = ['#style','#stores','#influencers','#items'];

    this.setAnalytics();

    _.each(this.qEls,function(qEl){
      $(qEl).popover({
        placement: 'bottom',
        animation: true,
        delay : 0
      });    
    });
  },

  // Fire tracking events
  //
  setAnalytics: function() {
    analytics.welcomeView();
    analytics.userCreated(); 
  }

});
