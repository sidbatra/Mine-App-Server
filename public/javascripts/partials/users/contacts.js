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
    this.contactsEl     = '#contacts';
    this.queryEl        = '#search_box';

    this.fbInviteBox    = new Denwen.Partials.Facebook.Invite();

    this.fbInviteBox.bind('inviteCompleted',this.inviteCompleted,this);
    this.fbInviteBox.bind('inviteCancelled',this.inviteCancelled,this);

    this.get();
  },

  // Fetches the contacts 
  //
  get: function() {
    var self      = this;
    this.contacts = new Denwen.Collections.Contacts();

    this.contacts.fetch({
          success:  function(collection){
                      self.render(self.contacts.toArray());
                      $(self.queryEl).show();
                      },
          error:    function(collection,errors){}
          });
  },

  // Render the contacts collection
  //
  render: function(contacts) {
    $(this.contactsEl).html(
      Denwen.JST['users/contacts']({contacts : contacts}));

    this.fbInviteBox.hookUp();
  },

  // Filter contacts based on the query
  //
  filter: function(e) {
    var query             = $(this.queryEl).val();
    var regex             = new RegExp(query,'i');

    var filteredContacts  = this.contacts.filter(
                              function(contact){
                                return contact.get('name').search(regex) == 0;
                              });
    
    this.render(filteredContacts);
  },

  // Reset the search box and the contacts list 
  //
  reset :function() {
    $(this.queryEl).val('');
    this.render(this.contacts.toArray());
  },

  // Fired when the user completes an invite
  //
  inviteCompleted: function(fb_id) {
    var contact = this.contacts.find(
                        function(contact){ 
                          return contact.get('third_party_id')==fb_id
                        });

    this.contacts.remove(contact);
    this.reset();
  },   

  // Fired when the user cancels an invite
  //
  inviteCancelled: function() {
    this.reset();
  } 

});
