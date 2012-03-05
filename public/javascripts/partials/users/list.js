// Partial to load and display a list of users
//
Denwen.Partials.Users.List = Backbone.View.extend({

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
    this.count    = this.options.count;
    this.src      = this.options.src;

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
      $(this.el).hide();

    $(this.el).html(
      Denwen.JST['users/list']({
        users   : this.users,
        leader  : this.user,
        count   : this.count,
        src     : this.src}));
  }

});
