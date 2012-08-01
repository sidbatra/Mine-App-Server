Denwen.Partials.Followings.Following = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self          = this;
    this.disabled     = false;

    this.userID       = this.options.userID;

    this.createEl     = "#create_following_" + this.userID;
    this.destroyEl    = "#destroy_following_" + this.userID;

    this.following    = new Denwen.Models.Following(this.options.followingJSON);

    this.preprocess(this.following);
    //this.following  = new Denwen.Models.Following({id:this.userID});
    //this.following.fetch({ 
    //    success : function(result) {self.preprocess(result);},
    //    error   : function(model,errors) {}
    //  });
  },

  // Based on the result of the show request
  // set the state of the following data member
  // to enable further follow / unfollow requests
  //
  preprocess: function(result) {

    if(!result.get('is_active')) {
      this.following = new Denwen.Models.Following();
      this.render(false);
    }
    else {
      this.render(true);
    }
  },

  // Create a following between the current user and the following
  //
  create: function() {

    if(this.disabled)
      return;

    this.disabled = true;
    this.render(true);

    this.following.save({user_id : this.userID});

    //Denwen.Track.followingCreated(this.userID);
  },

  // Destroy the current following
  //
  destroy: function() {

    if(this.disabled)
      return;

    this.disabled = true;
    this.render(false);

    this.following.destroy();
    this.following = new Denwen.Models.Following();

    //Denwen.Track.followingDestroyed(this.userID);
  },

  // Fired when the mouse leaves either create or destroy
  //
  mouseOut: function() {
    this.disabled = false;
  },

  // Render an action button representing the current
  // state of the following and the ability to
  // toggle it
  //
  render: function(isFollowing) {
    var self = this;

    $(this.createEl).unbind('click');
    $(this.destroyEl).unbind('click');
    $(this.createEl).unbind('mouseout');
    $(this.destroyEl).unbind('mouseout');

    this.el.html(
      Denwen.JST['followings/following']({
        isFollowing  : isFollowing,
        userID       : this.userID}));

    $(this.createEl).click(function() {self.create();});
    $(this.destroyEl).click(function() {self.destroy();});
    $(this.createEl).mouseout(function() {self.mouseOut();});
    $(this.destroyEl).mouseout(function() {self.mouseOut();});
  }

});
