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

    this.ifollowersEl       = '#ifollowers';
    this.followingMsg       = '#following_msg';

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
    var self = this;
    window.setTimeout(function(){self.get();},5000);
  },

  // Render the users collection
  //
  render: function() {
    var self = this;

    this.users.each(function(user){
      new Denwen.Partials.User({el:$(self.ifollowersEl),model:user});
    });

    //$(this.ifollowersEl).append(followers.get('html'));
  },

});
