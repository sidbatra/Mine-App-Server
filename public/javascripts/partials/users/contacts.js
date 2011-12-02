// Partial to load, display and search user's contacts 
//
Denwen.Partials.Users.Contacts = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
    "keyup #search_box" : "filter"
  },

  // Constructor logic
  //
  initialize: function() {
    this.contactsEl = '#contacts';
    this.queryEl    = '#search_box';

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
    $(this.contactsEl).html(
      Denwen.JST['users/contacts']({contacts : this.contacts.toArray()}));
  },

  // Filter contacts based on the query
  //
  filter: function(e){
    var query             = $(this.queryEl).val();
    var regex             = new RegExp(query,'i');

    var filteredContacts  = this.contacts.filter(
                              function(contact){
                                return contact.get('name').search(regex) == 0;
                              });
    
    $(this.contactsEl).html(
      Denwen.JST['users/contacts']({contacts : filteredContacts}));
  }

});
