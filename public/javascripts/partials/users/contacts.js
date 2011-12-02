// Partial to load and display user's contacts 
//
Denwen.Partials.Users.Contacts = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.get();
  },

  // Fetches the contacts 
  //
  get: function() {
    var self      = this;
    this.contacts = new Denwen.Collections.Contacts();

    this.contacts.fetch({
            success:  function(collection){self.render();},
            error:    function(collection,errors){}
            });
  },

  // Render the contacts collection
  //
  render: function() {
    $(this.el).html(
      Denwen.JST['users/contacts']({contacts : this.contacts}));
  }

});
