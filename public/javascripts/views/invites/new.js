// View for creating one or multiple invites
//
Denwen.Views.Invites.New = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {

    new Denwen.Partials.Users.Contacts({el:$('#contacts_container')});
                        
    // -----
    this.setAnalytics();
  },

  // Fire various tracking events 
  //
  setAnalytics: function() {

  }
  
});
