// Partial for loading and searching friends to invite
//
Denwen.Partials.Invites.Friends = Backbone.View.extend({
  
  // Setup event handlers
  //
  events: {
    "keyup #search_box" : "filter",
    "click #x_button"   : "searchCancelled"
  },

  // Constructor logic
  //
  initialize: function() {
    this.friends          = this.options.friends;
    this.inviteHandle     = this.options.invite_handle;

    this.contactsEl       = '#contacts';
    this.queryEl          = '#search_box';
    this.cancelSearchEl   = '#x_button';

    this.friendSearchTracked = false;

    this.fetch();
  },

  // Fetches the contacts 
  //
  fetch: function() {
    var self      = this;
    this.contacts = new Denwen.Collections.Contacts();

    this.contacts.fetch({
          success:  function(collection){
                      self.removeFriends();
                      self.render(self.contacts);
                      if($(self.queryEl).val().length)self.filter();},
          error:    function(collection,errors){}
          });
  },

  // Interface to launch an explicit search.
  //
  search: function(query) {
    $(this.queryEl).val(query);

    if(this.contacts && !this.contacts.isEmpty())
      this.filter();
  },

  // Filter out existing friends from contacts
  //
  removeFriends: function() {
    var friendIDs = new Array();
    this.friends.each(function(friend){
                        friendIDs[friend.get('fb_user_id')] = 1;});

    if(friendIDs.length) {
      var contacts = this.contacts.reject(function(contact){
                             return friendIDs[contact.get('third_party_id')]});

      this.contacts = new Denwen.Collections.Contacts(contacts);
    }
  },

  // Hookup invite functionality for all friends 
  //
  hookup: function(contacts) {
    var self = this;

    contacts.each(function(contact){
      new Denwen.Partials.Invites.New({
                            recipient : contact,
                            handle    : self.inviteHandle});
    });
  },

  // Render the contacts collection
  //
  render: function(contacts) {
    var self = this;

    $(this.contactsEl).html(
      Denwen.JST['contacts/contacts'](
        {contacts: contacts}));

    this.hookup(contacts);

    $(this.queryEl).phocus();
  },

  // Filter contacts based on the query
  //
  filter: function(e) {
    var query             = $(this.queryEl).val();
    var filteredContacts  = this.contacts.filter(
                              function(contact){
                                return ~contact.get('name').toLowerCase().
                                        indexOf(query.toLowerCase());
                              });
    
    this.render(new Denwen.Collections.Contacts(filteredContacts));

    if(query){
      $(this.cancelSearchEl).show();

      if(!this.friendSearchTracked) {
        this.friendSearchTracked = true;
        Denwen.Track.action("Invite Friend Search Started");
      }
    }
    else
      $(this.cancelSearchEl).hide();
  },

  // Reset the search box and the contacts list 
  //
  reset: function() {
    $(this.queryEl).val('');
    $(this.queryEl).focus();
    $(this.cancelSearchEl).hide();

    this.render(this.contacts);
  },

  // Fired when the user cancels a friend search
  //
  searchCancelled: function() {
    this.reset();
    Denwen.Track.action("Invite Friend Search Cancelled");
  }
  
});
