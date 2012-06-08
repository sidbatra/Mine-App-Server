// Partial to create new comment 
//
Denwen.Partials.Comments.New = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self          = this;

    this.purchase      = this.options.purchase;
    this.retry        = true;

    this.inputEl      = '#purchase_comment_data_' + this.purchase.get('id');
    $(this.inputEl).keypress(function(e){self.commentKeystroke(e)});
    $(this.inputEl).placeholder();

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

  // Fired after every keystroke on the comments data input.
  //
  commentKeystroke: function(e) {
    if(e.keyCode==13)
      this.prepare();
  },

  // Create a comment 
  //
  post: function(render) {
    if(!$(this.inputEl).val())
      return;

    var self      = this;

    var comment   = new Denwen.Models.Comment({
                     purchase_id : this.purchase.get('id'),
                     message    : $(this.inputEl).val(),
                     from       : {
                                  'id'  :Denwen.H.currentUser.get('fb_user_id'),
                                  'name':Denwen.H.currentUser.get('full_name')}
                    });

    if(render)
      this.render(comment);

    comment.save({},{
        success :  function(model) {self.created(model)},
        error   :  function(model,errors) {}
    });
  },

  // Decide whether to create an optimistic comment or show a spinner
  // and wait for feedback from the server
  //
  decide: function() {
    if(!this.purchase.hasSharingUnderway()) {
      this.post(true);
    }
    else {
      $(this.inputEl).addClass('load');
      this.post(false);
    }
  },

  // Fired when the user wants to write a comment 
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
    Denwen.Drawer.error("Please allow Facebook permissions to write comments.");
  },

  // Render the comment created before sending the request
  // to our server
  //
  render: function(comment) {
    Denwen.NM.trigger(
        Denwen.NotificationManager.Callback.CommentCreated,
        comment);

    $(this.inputEl).val('');
    $(this.inputEl).focus();
  },

  // Called when the comment is successfully created
  //
  created: function(comment) {
    if(!comment.get('id')) {
      
      if(this.purchase.hasSharingUnderway() && this.retry) {
        var self    = this; 
        this.retry  = false;

        setTimeout(function(){
                    self.post(false);
                   },4000);
      }
      else {
        $(this.inputEl).removeClass('load');
        Denwen.Drawer.error("Error posting comment. Try again in a second.");
      }
    }
    else if(this.purchase.hasSharingUnderway()) {
      $(this.inputEl).removeClass('load');
      this.render(comment);
    }

    Denwen.Track.action("Comment Created");
  }

});
