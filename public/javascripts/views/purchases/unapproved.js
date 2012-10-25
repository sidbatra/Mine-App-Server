Denwen.Views.Purchases.Unapproved = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.source = this.options.source;

    this.feedEl  = '#feed';
    this.feedSpinnerEl  = '#feed-spinner';

    if(!Denwen.H.isOnboarding) {
      new Denwen.Partials.Purchases.Unapproved.Live({
            el:$(this.feedEl),
            spinnerEl:this.feedSpinnerEl});
    }
    else {
      new Denwen.Partials.Purchases.Unapproved.Stale({
            el:$(this.feedEl),
            spinnerEl:this.feedSpinnerEl});
    }

    this.setAnalytics();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    Denwen.Track.action("Unapproved Purchases View",{"Source" : this.source});

    if(Denwen.H.isOnboarding)
      Denwen.Track.action("Welcome Purchase Email View");
  }

});
