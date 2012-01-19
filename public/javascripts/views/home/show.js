// View js for the Home/Show route
//
Denwen.Views.Home.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.source   = this.options.source;
    this.origin   = this.options.origin;

    new Denwen.Partials.Facebook.Session({
                                      el      : $('#container'),
                                      origin  : this.origin});

    // -----
    this.loadFacebookPlugs();

    // -----
    this.setAnalytics();
  },

  // Load facebook code via partials
  //
  loadFacebookPlugs: function() {
    new Denwen.Partials.Facebook.Base();
  },

  // Fire various tracking events 
  //
  setAnalytics: function() {
     mpq.register_once({'landed_on' : this.origin});

     mpq.track('landed on homepage', {
          'source'  : this.source,
          'origin'  : this.origin});
  }

});
