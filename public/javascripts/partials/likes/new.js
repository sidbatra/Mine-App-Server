// Partial to create new like 
//
Denwen.Partials.Likes.New = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self          = this;

    this.productID    = this.options.product_id;
    this.posting      = false;

    this.buttonEl     = '#product_create_like_' + this.productID;

    $(this.buttonEl).click(function(){self.prepare();});

    this.fbPermissionsRequired = 'fb_publish_permissions';

    this.fbSettings = new Denwen.Partials.Settings.Facebook({
                            permissions : this.fbPermissionsRequired});

    this.fbSettings.bind(
                      'fbSettingsFetched',
                      this.fbSettingsFetched,
                      this);
  },

  // Create a like 
  //
  post: function() {
    if(this.posting)
      return;

    var self      = this;
    this.posting  = true;

    var like = new Denwen.Models.Like({
                product_id  : this.productID,
                user_id     : Denwen.H.currentUser.get('fb_user_id'),
                name        : Denwen.H.currentUser.get('full_name')});

    this.render(like);

    like.save({},{
        success :  function(model) {self.created(model)},
        error   :  function(model,errors) {}
    });
  },

  // Fired when the user wants to create a like
  //
  prepare: function() {
    if(Denwen.H.currentUser.get('setting').get(this.fbPermissionsRequired))
      this.post();
    else  
      this.fbSettings.showPermissionsDialog();
  },

  // Fired when the updated fb permissions settings
  // are fetched
  //
  fbSettingsFetched: function() {

    if(Denwen.H.currentUser.get('setting').get(this.fbPermissionsRequired)) {
      Denwen.Track.facebookPermissionsAccepted();
      this.post();
    }
    else {
      Denwen.Drawer.error("Please allow Facebook permissions to like.");
      Denwen.Track.facebookPermissionsRejected();
    }
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
      console.log("error in creating");
    }
  },

  // Change the state of the button if a user likes/has liked an item
  //
  disable: function() {
    $(this.buttonEl).addClass('pushed');
    $(this.buttonEl).unbind('click');
  }

});
