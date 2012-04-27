// View js for the Users/Show route
//
Denwen.Views.Users.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.user           = new Denwen.Models.User(this.options.userJSON);
    this.isCurrentUser  = Denwen.H.isCurrentUser(this.user.get('id'));
    this.source         = this.options.source;

    if(this.options.currentUserJSON != 'false')
      this.currentUser  = new Denwen.Models.User(this.options.currentUserJSON);

    // -----
    //if(this.isCurrentUser)
    //  new Denwen.Partials.Users.Byline({
    //                model: this.user, 
    //                el:$('#profile_bio')});

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

    Denwen.Track.userLandsOn(this.user.uniqueKey());

    Denwen.Track.userProfileView(
      this.source,
      this.user.get('id'));

    if(this.isCurrentUser) {

      if(this.source == 'purchase_deleted')
        Denwen.Track.purchaseDeleted();

      Denwen.Track.identifyUser(
        this.currentUser.get('email'),
        this.currentUser.get('age'),
        this.currentUser.get('gender'));

      Denwen.Track.trackVersion(Denwen.H.version.slice(0,-2));
    }

    Denwen.Track.checkForEmailClickedEvent(this.source);
  }
  
});
