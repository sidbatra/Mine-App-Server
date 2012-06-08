// View js for the Users/Show route
//
Denwen.Views.Users.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.user           = new Denwen.Models.User(this.options.userJSON);
    this.source         = this.options.source;


    // -----
    if(Denwen.H.isCurrentUser(this.user.get('id')))
      new Denwen.Partials.Users.Byline({
            el: $('#user_byline_box'),
            model: this.user});

    $("a[rel='tooltip']").tooltip();

    // -----
    this.loadFacebookPlugs();

    // -----
    this.displayFlashMessage();

    // -----
    this.setAnalytics();
  },

  // Load facebook code via partials
  //
  loadFacebookPlugs: function() {
    new Denwen.Partials.Facebook.Base();
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
