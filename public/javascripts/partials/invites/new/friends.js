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
    this.contactsEl       = '#contacts';
    this.queryEl          = '#search_box';
    this.cancelSearchEl   = '#x_button';
    this.styleID          = 0;

    this.fetch();
  },

  // Fetches the contacts 
  //
  fetch: function() {
    var self      = this;
    this.contacts = new Denwen.Collections.Contacts();

    this.contacts.fetch({
          success:  function(collection){self.render(self.contacts);},
          error:    function(collection,errors){}
          });
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
