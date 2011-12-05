// Partial to load, display and search user's contacts 
//
Denwen.Partials.Users.Contacts = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
    "keyup #search_box" : "filter",
    "click #x_button"   : "searchCancelled"
  },

  // Constructor logic
  //
  initialize: function() {
    this.contactsEl           = '#contacts';
    this.queryEl              = '#search_box';
    this.multiInviteEl        = '#multi_invite_box';
    this.cancelSearchEl       = '#x_button';
    this.spinnerEl            = '#loading_spinner';
    this.searchContainerEl    = '#invite_search_container';
    this.searchTitleEl        = '#invite_textfield_title';

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
          success:  function(collection){self.fetched();},
          error:    function(collection,errors){}
          });
  },

  // Fired when the contacts json has been fetched from
  // the server
  //
  fetched: function(){
    if(this.contacts.length) {
      $(this.queryEl).show();
      $(this.queryEl).focus();
      $(this.searchTitleEl).show();

      this.render(this.contacts);
    }
    else {
      this.fbInviteBox.hookUp();
      this.fbInviteBox.showMultiInviteDialog();

      $(this.multiInviteEl).show();
      $(this.spinnerEl).hide();
      $(this.searchContainerEl).hide();
    }
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
    var regex             = new RegExp('(^|.* )' + query,'i');

    var filteredContacts  = this.contacts.filter(
                              function(contact){
                                return contact.get('name').search(regex) == 0;
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
  },

  // Fired when the user completes an invite
  //
  inviteCompleted: function(fb_id) {
    var contact = this.contacts.find(
                        function(contact){ 
                          return contact.get('third_party_id')==fb_id;
                        });

    this.contacts.remove(contact);
    this.reset();
  },   

  // Fired when the user cancels an invite
  //
  inviteCancelled: function() {
    $(this.queryEl).focus();
  } 

});
