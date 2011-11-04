// User's iFollowers 
//
Denwen.UserIFollowersView = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self            = this;
    this.id             = this.options.id;

    this.ifollowersEl   = '#ifollowers';
    this.followingMsgEl = '#following_msg';

    window.setTimeout(function(){self.get();},5000);
  },

  // Called when the iFollowers are successfully fetched 
  //
  fetched: function(users) {
    $(this.ifollowersEl).append(users.at(0).get('html'));
    $(this.followingMsgEl).html(users.at(0).get('msg'));
  },

  // Fetches the iFollowers 
  //
  get: function() {
    var self  = this;
    var users = new Denwen.Users();

    users.fetch({
            data:     {id: this.id},
            success:  function(collection){self.fetched(collection)},
            error:    function(collection,errors){}
            });
  }
});
