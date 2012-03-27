// Partial for loading and selecting a friend to invite
//
Denwen.Partials.Invites.New.Friends = Backbone.View.extend({
  
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

    this.contactsEl       = '#contacts';
    this.queryEl          = '#search_box';
    this.cancelSearchEl   = '#x_button';
    this.buttonEl         = '#friend_picked_button';

    this.contactPickers   = new Array();

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
                      self.render(self.contacts);},
          error:    function(collection,errors){}
          });
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

  // Hookup pick/unpick functionality for all friends 
  //
  hookup: function(contacts) {
    var self = this;
    this.contactPickers = [];

    contacts.each(function(contact){
      var contactPicker = new Denwen.Partials.Contacts.Picker({model:contact});

      contactPicker.bind(
        'contactPicked',
        self.contactPicked,
        self);
      
      self.contactPickers.push(contactPicker);
    });
  },

  // Fired when a contact is picked
  //
  contactPicked: function(contactPicker) {
    this.contact = contactPicker.model;
    
    $.each(this.contactPickers,function(i,picker) {
      picker.disable();
    });

    contactPicker.enable();

    $(this.buttonEl).attr(
                      'href',
                      '#friends-' + 
                      this.contact.get('name').replace(' ','+') + '-' + 
                      this.contact.get('third_party_id') + '/finish');

    $(this.buttonEl).addClass('btn-primary');
    $(this.buttonEl).removeClass('disabled'); 
    $(this.buttonEl).html(
      "Preview Invite <i class='icon-chevron-right icon-white'></i>");
  },

  // Fired when the friends sub view comes into focus
  //
  display: function() {

    if(this.contacts && !this.contacts.isEmpty())
      this.render(this.contacts);

    $(this.queryEl).val('');
    $(this.cancelSearchEl).hide();

    analytics.inviteStylePicked();
  },

  // Fired when the sub view has come into focus
  displayed: function() {
    $(this.queryEl).focus();
  },

  // Render the contacts collection
  //
  render: function(contacts) {
    var self = this;

    $(this.contactsEl).html(
      Denwen.JST['contacts/contacts'](
        {contacts: contacts}));

    this.hookup(contacts);
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
      analytics.friendSearched(query);
    }
    else
      $(this.cancelSearchEl).hide();
  },

  // Reset the search box and the contacts list 
  //
  reset :function() {
    $(this.queryEl).val('');
    $(this.queryEl).focus();
    $(this.cancelSearchEl).hide();

    this.render(this.contacts);
  },

  // Fired when the user cancels a friend search
  //
  searchCancelled: function() {
    this.reset();
    analytics.friendSearchCancelled();
  }
  
});
