// Partial to load and display user's iFollowers 
//
Denwen.Partials.Users.PreviewBox = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self      = this;
    this.user     = this.options.user;
    this.filter   = this.options.filter;
    this.header   = this.options.header;
    this.count    = this.options.count;
    this.hash     = this.options.hash;

    this.get();
  },

  // Fetches the iFollowers 
  //
  get: function() {
    var self    = this;
    this.users  = new Denwen.Collections.Users();

    this.users.fetch({
            data:     {id: this.user.get('id'), filter: self.filter},
            success:  function(collection){self.render();},
            error:    function(collection,errors){}
            });
  },

  // Render the users collection
  //
  render: function() {
    var self = this;
    
    if(this.users.isEmpty() && !helpers.isCurrentUser(this.user.get('id')))
      $(this.el).parent().hide();

    $(this.el).html(
      Denwen.JST['users/preview_box']({
        users   : this.users,
        leader  : this.user,
        header  : this.header,
        count   : this.count,
        hash    : this.hash}));
  }

});
