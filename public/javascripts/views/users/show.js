// View js for the Users/Show route
//
Denwen.Views.Users.Show = Backbone.View.extend({
  
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

    if(this.source == "mined")
      Denwen.Drawer.success("Import successful. Mine will notify you when you have new items.",0);

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
