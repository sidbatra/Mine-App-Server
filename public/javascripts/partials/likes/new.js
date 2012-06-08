// Partial to create new like 
//
Denwen.Partials.Likes.New = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self          = this;

    this.purchase      = this.options.purchase;
    this.posting      = false;
    this.retry        = true;

    this.buttonEl     = '#purchase_create_like_' + this.purchase.get('id');

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
                purchase_id : this.purchase.get('id'),
                fb_user_id  : Denwen.H.currentUser.get('fb_user_id'),
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
    if(!this.purchase.hasSharingUnderway()) {
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
    if(this.purchase.isNative() || 
          Denwen.H.currentUser.get('setting').get(this.fbPermissionsRequired)) 
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

      if(this.purchase.hasSharingUnderway() && this.retry) {
        var self    = this; 
        this.retry  = false;

        setTimeout(function(){
                    self.post(false);
                   },4000);
      }
      else {
        $(this.buttonEl).removeClass('load');
        Denwen.Drawer.error("Error posting like. Try again in a second.");
      }
    }
    else if(this.purchase.hasSharingUnderway()) {
      $(this.buttonEl).removeClass('load');
      this.render(like);
    }

    Denwen.Track.action("Like Created");
  },

  // Change the state of the button if a user likes/has liked an item
  //
  disable: function() {
    $(this.buttonEl).addClass('pushed');
    $(this.buttonEl).unbind('click');
  }

});
