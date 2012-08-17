// 
//
Denwen.Views.Welcome.Show = Backbone.View.extend({
  
  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.feedEl = '#feed';

    this.content  = new Denwen.Partials.Feed.Content({
                          aspect: 'special',
                          el:$(this.feedEl),
                          interactive:false});

    this.setAnalytics();
  },

  // Fire tracking events
  //
  setAnalytics: function() {
    Denwen.Track.action("Welcome View");
    Denwen.Track.action("$born");
    Denwen.Track.action("User Created");

    Denwen.Track.user(
      Denwen.H.currentUser.get('id'),
      Denwen.H.currentUser.get('full_name'),
      Denwen.H.currentUser.get('email'),
      Denwen.H.currentUser.get('age'),
      Denwen.H.currentUser.get('gender'),
      Denwen.H.currentUser.get('created_at')); 
  }

});
