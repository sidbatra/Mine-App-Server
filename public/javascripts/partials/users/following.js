Denwen.Partials.Users.Following = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self        = this;
    this.userID     = this.options.user_id;
    this.following  = new Denwen.Models.Following({id:this.userID});

    this.following.fetch(
      { 
        success : function(result) {self.preprocess(result);},
        error   : function(model,errors) {}
      });
  },

  // Based on the result of the show request
  // set the state of the following data member
  // to enable further follow / unfollow requests
  //
  preprocess: function(result) {
    if(!result.has('is_active')) 
      this.following = new Denwen.Models.Following();

    this.render();
  },

  // Create a following between the current user and the following
  //
  create: function() {
    var self = this;

    this.following.save({
            user_id : this.userID},{
            success : function(){self.render();}});
  },

  // Destroy the current following
  //
  destroy: function() {
    var self = this;

    this.following.destroy({
            success : function() {
                        self.following = new Denwen.Models.Following();
                        self.render();}});
  },

  // Render an action button representing the current
  // state of the following and the ability to
  // toggle it
  //
  render: function() {
    var self = this;

    $('#create_following').unbind('click');
    $('#destroy_following').unbind('click');

    this.el.html(
      Denwen.JST['followings/following']({
        following  : this.following}));

    $('#create_following').click(function() { self.create();});
    $('#destroy_following').click(function() {self.destroy();});
    
  }

});
