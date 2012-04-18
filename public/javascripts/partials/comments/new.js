// Partial to create new comment 
//
Denwen.Partials.Comments.New = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self          = this;

    this.productID    = this.options.product_id;

    this.inputEl      = '#product_comment_data_' + this.productID;
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
  post: function() {
    if(!$(this.inputEl).val())
      return;

    var self      = this;

    var comment   = new Denwen.Models.Comment({
                     product_id : this.productID,
                     message    : $(this.inputEl).val(),
                     from       : {
                                  'id'  :Denwen.H.currentUser.get('fb_user_id'),
                                  'name':Denwen.H.currentUser.get('full_name')}
                    });

    this.render(comment);

    comment.save({},{
        success :  function(model) {self.created(model)},
        error   :  function(model,errors) {}
    });
  },

  // Fired when the user wants to write a comment 
  //
  prepare: function() {
    if(Denwen.H.currentUser.get('setting').get(this.fbPermissionsRequired))
      this.post();
    else  
      this.fbSettings.showPermissionsDialog();
  },

  // Fired when fb permissions are accepted 
  //
  fbPermissionsAccepted: function() {
    this.post();
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
      console.log("error in creating");
    }
  }

});
