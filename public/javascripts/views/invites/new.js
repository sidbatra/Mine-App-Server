// View for creating one or multiple invites
//
Denwen.Views.Invites.New = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {

    new Denwen.Partials.Users.Contacts({el:$('#container')});
                        
    // -----
    this.loadFacebookPlugs();
  },

  // Load facebook code via partials
  //
  loadFacebookPlugs: function() {
    new Denwen.Partials.Facebook.Base();
  }

});
