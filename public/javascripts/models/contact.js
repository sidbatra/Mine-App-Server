// The Contact model represents a user contact 
//
Denwen.Models.Contact = Backbone.Model.extend({

  // Route on the app server
  //
  urlRoot: '/contacts',

  // Constructor logic
  //
  initialize: function() {
  },

  // URL for the contact image 
  //
  imageURL: function() {
    return "http://graph.facebook.com/" + 
            this.get('third_party_id') + "/picture?type=square"
  }

});


