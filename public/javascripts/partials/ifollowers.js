// Partial to load and display user's iFollowers 
//
Denwen.Partials.IFollowers = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self                = this;

    this.id                 = this.options.id;
    this.el                 = '#ifollowers_with_msg';

    this.get();
  },

  // Fetches the iFollowers 
  //
  get: function() {
    var self    = this;
    this.users  = new Denwen.Collections.Users();

    this.users.fetch({
            data:     {id: this.id, filter: 'ifollowers'},
            success:  function(collection){self.render();},
            error:    function(collection,errors){}
            });
  },

  // Fetches the iFollowers after timeout
  //
  getAfterTimeout: function() {
    console.log("in get After Timeout");
    var self = this;
    window.setTimeout(function(){self.get();},5000);
  },

  // Render the users collection
  //
  render: function() {
    console.log("i followers rendered");
    console.log(this.users.length);
    var self = this;

    $(this.el).html(
      Denwen.JST['users/ifollowers']({
        users   : this.users,
        userID  : this.options.id}));
  }

});
