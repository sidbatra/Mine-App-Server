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

    this.styleID          = 0;
    this.selectedPicker   = null;

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

  // Setup pick/unpick functionality for all friends 
  //
  setup: function() {
    var self = this;

    this.contacts.each(function(contact){
      var contactPicker = new Denwen.Partials.Contacts.Picker({model:contact});

      contactPicker.bind(
        'contactPicked',
        self.contactPicked,
        self);
    });
  },

  // Fired when a contact is picked
  //
  contactPicked: function(contactPicker) {
    this.contact = contactPicker.model;

    if(this.selectedPicker)
      this.selectedPicker.restore();
    
    contactPicker.enable();

    $(this.buttonEl).attr(
                      'href',
                      '#styles-' + this.styleID + '/friends-' + 
                      this.contact.get('name').replace(' ','+') + '-' + 
                      this.contact.get('third_party_id') + '/finish');

    $(this.buttonEl).addClass('btn-primary');
    $(this.buttonEl).removeAttr('disabled'); 
    $(this.buttonEl).html(
      "Preview Invite <i class='icon-chevron-right icon-white'></i>");

    this.selectedPicker = contactPicker;
  },

  // Fired when the friends sub view comes into focus
  //
  display: function(styleID) {
    this.styleID = styleID;

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
        {contacts: contacts,
          styleID: self.styleID}));

    this.setup();
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
