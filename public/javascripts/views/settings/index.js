// Edit settings
//
Denwen.Views.Settings.Index = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.source = this.options.source;

    this.setAnalytics();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    analytics.settingsView(this.source);

    if(this.source.slice(0,6) == 'email_')
      analytics.unsubscribeInitiated(this.source.slice(6,this.source.length));
  }

});

