// View for following suggested users while onboarding 
//
Denwen.Views.Welcome.Followings = Backbone.View.extend({
  
  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self            = this;

    this.source         = this.options.source;
    this.userIds        = $.makeArray(this.options.users);

    this.formEl         = '#new_followings';
    this.userIdsEl      = '#user_ids';

    this.posting        = false;
    this.followings     = new Array(); 

    $(this.formEl).submit(function(){return self.post();});

    this.setup();
    this.setAnalytics();
  },

  // Setup follow/unfollow functionality for all 
  // suggested users
  //
  setup: function(){
    var self = this;

    this.userIds.forEach(function(userID){
      var following = new Denwen.Partials.Users.Following({
                        el           : $('#following_box_' + userID.toString()),
                        user_id      : userID,
                        is_suggested : true });

      following.bind('addToUsersFollowed',self.addToUsersFollowed,self);
      following.bind('removeFromUsersFollowed',
                          self.removeFromUsersFollowed,self);

      self.followings.push(following);
    });
  },

  // Fired when a user is explicitly followed
  //
  addToUsersFollowed: function(userID) {
    this.userIds.push(userID);
  },

  // Fired when a user is unfollowed 
  //
  removeFromUsersFollowed: function(userID) {
    this.userIds = _.without(this.userIds,userID);
  },

  // Form submitted callback
  //
  post: function() {

    if(this.posting)
      return false;

    this.posting = true;
    
    $(this.userIdsEl).val(this.userIds.join(","));

    return true;
  },

  // Fire tracking events
  //
  setAnalytics: function() {

  }

});
