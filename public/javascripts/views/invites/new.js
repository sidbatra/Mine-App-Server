// View for creating one or multiple invites
//
Denwen.Views.Invites.New = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.source = this.options.source;

    new Denwen.Partials.Users.Contacts({el:$('#container')});
                        
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

  // Fire tracking events
  //
  setAnalytics: function() {
    analytics.inviteView(this.source);

    if(this.source == 'login')
      analytics.userCreated(); 
  }

});
