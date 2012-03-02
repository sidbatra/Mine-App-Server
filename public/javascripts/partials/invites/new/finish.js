// Partial for displaying the final invite confirmation and creating invites
//
Denwen.Partials.Invites.New.Finish = Backbone.View.extend({
  
  // Setup event handlers
  //
  events: {
    "click #send_invite"   : "sendInvite"
  },

  // Constructor logic
  //
  initialize: function() {
    this.largeNameEl  = '#friend_name_large';
    this.smallNameEl  = '#friend_name_small';
    this.bylineEl     = '#friend_byline';
    this.imageEl      = '#friend_image';
  },

  // Fired just before the view is coming into focus
  //
  display: function(byline,name,fbID) {
    var firstName = name.split(' ')[0];

    $(this.largeNameEl).html(firstName);
    $(this.smallNameEl).html(firstName);
    $(this.bylineEl).html(byline);
    $(this.imageEl).attr(
      "src",
      "https://graph.facebook.com/" + fbID + "/picture?type=large");
  },

  // Fired when the user wants to send the invite
  //
  sendInvite: function() {
    console.log("SEND INVITE");
  }

});
