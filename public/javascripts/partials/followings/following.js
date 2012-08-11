Denwen.Partials.Followings.Following = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self          = this;
    this.external     = false;
    this.disabled     = true;
    this.placeholder  = !Denwen.H.isLoggedIn();
    this.tag          = this.options.tag;
    this.userID       = this.options.userID;
    this.fetch        = this.options.fetch;

    if (typeof this.tag  === "undefined")
      this.tag = '';

    this.createEl     = "#create_following_" + this.userID + this.tag;
    this.destroyEl    = "#destroy_following_" + this.userID + this.tag;

    this.render(false);

    if(!this.placeholder){
      $(this.createEl).addClass('load');

      if (typeof this.fetch  === "undefined" || this.fetch == true)  {
        this.following  = new Denwen.Models.Following({id:this.userID});
        this.following.fetch({ 
          success : function(result) {self.evaluateUI(result);},
          error   : function(model,errors) {}
        });
      }

      Denwen.NM.bind(
        Denwen.NotificationManager.Callback.FollowingLoaded,
        this.externalFollowingLoaded,
        this);

      Denwen.NM.bind(
        Denwen.NotificationManager.Callback.FollowingLoadingComplete,
        this.externalFollowingLoadingComplete,
        this);
    }
  },

  // Based on the result of the show request
  // set the state of the following data member
  // to enable further follow / unfollow requests
  //
  preprocess: function(result) {

    if(!result.has('is_active') || !result.get('is_active')) {
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

    if(this.placeholder) {
      console.log("ACTIVATE PLACEHOLDER");
      return;
    }

    if(this.disabled)
      return;

    var self = this;

    this.disabled = true;

    $(this.createEl).addClass('load');

    this.following.save({user_id : this.userID},{
      success: function(result) {self.evaluateUI(result);},
      error: function(model,errors){}});

    Denwen.Track.action("Following Created");
  },

  // Destroy the current following
  //
  destroy: function() {

    if(this.disabled)
      return;

    var self = this;

    this.disabled = true;

    $(this.destroyEl).addClass('load');

    this.following.destroy({
      success: function(result) {self.evaluateUI(new Backbone.Model());},
      error: function(model,errors){}});

    Denwen.Track.action("Following Destroyed");
  },

  // Render an action button representing the current
  // state of the following and the ability to
  // toggle it
  //
  render: function(isFollowing) {
    var self = this;

    $(this.createEl).unbind('click');
    $(this.destroyEl).unbind('click');

    this.el.html(
      Denwen.JST['followings/following']({
        isFollowing  : isFollowing,
        userID       : this.userID,
        tag          : this.tag}));

    $(this.createEl).click(function() {self.create();});
    $(this.destroyEl).click(function() {self.destroy();});
  },

  // Update the UI status after a request has finished.
  //
  evaluateUI: function(result) {
    this.preprocess(result);
    this.disabled = false;
  },

  // External following is loaded via notification manager.
  //
  externalFollowingLoaded: function(following) {
    if(this.userID == following.get('user_id')) {
      this.following = following;
      this.evaluateUI(following);
      this.external = true;
    }
  },

  // All external followings have been loade.
  //
  externalFollowingLoadingComplete: function() {
    if(!this.external)
      this.evaluateUI(new Backbone.Model());
  }

});
