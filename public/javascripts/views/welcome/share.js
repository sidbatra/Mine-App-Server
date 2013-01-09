Denwen.Views.Welcome.Share = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
    "click #fb_share_button" : "showFacebookFeedDialog",
    "click #tw_share_button" : "showTweetDialog"
  },
  
  // Constructor logic
  //
  initialize: function() {
    this.user           = Denwen.H.currentUser;
    this.source         = this.options.source;

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

  // Show facebook feed dialog 
  //
  showFacebookFeedDialog: function() {
    var url     = 'http://getmine.com' + this.user.path('fb');
    var display = Denwen.Device.get("is_phone") ? 'touch' : 'popup';
    var text = null;

    if(Denwen.H.isOnboarding) {
      text = "Some things I've bought recently";
    }
    else {
      text = "My Mine has a few new items";
    }

    FB.ui({method: 'feed', 
      link: url,
      name:text,
      caption: 'getmine.com',
      description: 'View your purchase history · Browse · Shop',
      display: display},
      function(response) {});
  },

  showTweetDialog: function() {
    var url = 'http://getmine.com/' + this.user.get('handle');
    var ref = 'http://getmine.com';
    var text = null;
    
    if(Denwen.H.isOnboarding) {
      text = "Some things I've bought recently: ";
    }
    else {
      text = "Added a few new items to my Mine: ";
    }
    
    var twitterURL = 'https://twitter.com/intent/tweet?' +
                     'original_referer=' + encodeURIComponent(ref) + '&' + 
                     'related=getmine&' +
                     'text=' + encodeURIComponent(text) + '&' + 
                     'tw_p=tweetbutton&' + 
                     'url=' + encodeURIComponent(url);

    Denwen.H.popup(twitterURL,550,450);
  },

  // Fire various tracking events 
  //
  setAnalytics: function() {
    if(Denwen.H.isOnboarding)
      Denwen.Track.action("Welcome Share View");

    Denwen.Track.action("Share Profile View",{"Source" : this.source});
    Denwen.Track.isEmailClicked(this.source);
  }
  
});
