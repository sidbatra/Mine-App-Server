Denwen.Views.Welcome.Connect = Backbone.View.extend({

  initialize: function() {
    var self = this;

    this.successURL = this.options.successURL;

    new Denwen.Partials.Auth.Email({
        googleEl: '#google_connect_button',
        yahooEl: '#yahoo_connect_button',
        successURL: this.successURL});

    this.setAnalytics();
  },

  setAnalytics: function() {
    Denwen.Track.action("Welcome Connect");
  }

});

