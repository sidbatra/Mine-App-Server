// Partial to load and display user's followers 
//
Denwen.Partials.Users.Followers = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self            = this;
    this.user           = this.options.user;

    if(this.options.delay)
      window.setTimeout(function(){self.get();},5000);
    else
      this.get();
  },

  // Fetches the followers 
  //
  get: function() {
    var self    = this;
    this.users  = new Denwen.Collections.Users();

    this.users.fetch({
            data:     {id: this.user.get('id'), filter: 'followers'},
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
      Denwen.JST['users/followers']({
        users   : this.users,
        leader  : this.user}));
  }

});
