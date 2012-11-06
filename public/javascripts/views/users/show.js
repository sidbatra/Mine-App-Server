// View js for the Users/Show route
//
Denwen.Views.Users.Show = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
    "click #fb_share_button" : "showFacebookFeedDialog"
  },
  
  // Constructor logic
  //
  initialize: function() {
    this.user           = new Denwen.Models.User(this.options.userJSON);
    this.source         = this.options.source;

    // -----
    new Denwen.Partials.Users.Box({
      el: $('#user_box'),
      user: this.user
    });

    // -----
    $("span.timeago").timeago();

    // -----
    $("a[rel='tooltip']").tooltip();

    // -----
    //$(".source-url").click(function(){
    //                        Denwen.Track.purchaseURLVisit('profile')});

    // -----
    this.loadFacebookPlugs();

    // -----
    this.displayFlashMessage();

    if(this.source == 'mined') 
      this.loadTwitterPlugs();

    // -----
    this.setAnalytics();
  },

  // Load facebook code via partials
  //
  loadFacebookPlugs: function() {
    new Denwen.Partials.Facebook.Base();
  },

  // Load twitter plugings 
  //
  loadTwitterPlugs: function() {
    !function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="https://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");
  },

  // Show facebook feed dialog 
  //
  showFacebookFeedDialog: function() {
    var url     = 'http://getmine.com' + this.user.path('fb');
    var display = Denwen.Device.get("is_phone") ? 'touch' : 'popup';

    FB.ui({method: 'feed', 
      link: url,
      name:'Just added some new items on Mine',
      caption: 'getmine.com',
      description: 'You buy great things. Help others discover them too.',
      display: display},
      function(response) {});

    Denwen.Track.action("Profile shared on Facebook");
  },

  // Public. Display a success or failure message if a flash related
  // event has been initiated.
  //
  displayFlashMessage: function() {
    if(Denwen.Flash.get('destroyed') == true) {
      Denwen.Drawer.success("Your purchase has been deleted.");
      Denwen.Track.action("Purchase Deleted");
    }
    else if(Denwen.Flash.get('destroyed') == false)
      Denwen.Drawer.error("Sorry, there was an error deleting your purchase.");
  },

  // Fire various tracking events 
  //
  setAnalytics: function() {
    Denwen.Track.action("User View",{"Source" : this.source});
    Denwen.Track.isEmailClicked(this.source);
    Denwen.Track.origin("user");
  }
  
});
