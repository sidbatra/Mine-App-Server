// Partial to create new like 
//
Denwen.Partials.Likes.New = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self          = this;

    this.product      = this.options.product;
    this.posting      = false;

    this.buttonEl     = '#product_create_like_' + this.product.get('id');

    $(this.buttonEl).click(function(){self.prepare();});

    this.fbPermissionsRequired = 'fb_publish_permissions';

    this.fbSettings = new Denwen.Partials.Settings.Facebook({
                            permissions : this.fbPermissionsRequired});

    this.fbSettings.bind(
      Denwen.Partials.Settings.Facebook.Callback.PermissionsAccepted,
      this.fbPermissionsAccepted,
      this);

    this.fbSettings.bind(
      Denwen.Partials.Settings.Facebook.Callback.PermissionsRejected,
      this.fbPermissionsRejected,
      this);
  },

  // Create a like 
  //
  post: function(render) {
    if(this.posting)
      return;

    var self      = this;
    this.posting  = true;

    var like = new Denwen.Models.Like({
                product_id  : this.product.get('id'),
                user_id     : Denwen.H.currentUser.get('fb_user_id'),
                name        : Denwen.H.currentUser.get('full_name')});

    if(render)
      this.render(like);

    like.save({},{
        success :  function(model) {self.created(model)},
        error   :  function(model,errors) {}
    });
  },

  // Decide whether to create an optimistic like or show a spinner
  // and wait for feedback from the server
  //
  decide: function() {
    if(this.product.isShared()) {
      this.post(true);
    }
    else {
      $(this.buttonEl).addClass('load');
      this.post(false);
    }
  },

  // Fired when the user wants to create a like
  //
  prepare: function() {
    if(Denwen.H.currentUser.get('setting').get(this.fbPermissionsRequired)) 
      this.decide();
    else   
      this.fbSettings.showPermissionsDialog();
  },

  // Fired when fb permissions are accepted 
  //
  fbPermissionsAccepted: function() {
    this.decide();
  },

  // Fired when fb permissions are rejected
  //
  fbPermissionsRejected: function() {
    Denwen.Drawer.error("Please allow Facebook permissions to like an item.");
  },

  // Render the like before sending the request to the server 
  //
  render: function(like) {
    Denwen.NM.trigger(
                Denwen.NotificationManager.Callback.LikeCreated,
                like);
    
    this.disable();
  },

  // Called when the like is successfully created
  //
  created: function(like) {
    if(!like.get('id')) {
      this.posting = false;
      Denwen.Drawer.error("Error in posting like.");
    }
    else if(!this.product.isShared()) {
      this.render(like);
    }

    $(this.buttonEl).removeClass('load');
  },

  // Change the state of the button if a user likes/has liked an item
  //
  disable: function() {
    $(this.buttonEl).addClass('pushed');
    $(this.buttonEl).unbind('click');
  }

});
