// UserShowViewController provides a javascript interface for
// displaying a user

// UI elements
var kUserEditInitiate   = '#user_edit_initiate';
var kUserByline         = '#user_byline';
var kUserEdit           = '#user_edit';
var kUserUpdate         = '#user_update';
var kUserBylineText     = '#user_byline_text';


// Constructor logic
//
function UserShowViewController(user_id) {
  var usvController     = this;
  this.user_id          = user_id;

  restrictFieldSize($(kUserByline),254,'charsremain');

  $(kUserByline).keypress(function(e) { 
                        return usvController.userBylineKeyPressed(e); });

  //$(kUserByline).blur(function() { 
  //                      return usvController.updateUser(); });

  $(kUserEdit).click(function() { 
      usvController.userEditClicked();});

  $(kUserUpdate).click(function() { 
      usvController.updateUser();});

  $(kUserEditInitiate).click(function() { 
      usvController.userEditInitiateClicked(); });
}

// Update user
//
UserShowViewController.prototype.updateUser = function() {
  
  if($(kUserByline).val().length < 1) {
      //alert("Please enter a valid comment");
      return;
  }

  var usvController = this;

  $.ajax({
    type:       "PUT",
    url:        "/users/" + this.user_id + ".js?user[byline]=" + 
                $(kUserByline).val(),
    success:    function(d){usvController.userUpdated(d);},
    error:      function(r,s,e){usvController.userError(r,s,e);}
    });

  mpq.track("User Updated");
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Ajax event handlers
//-----------------------------------------------------------------------------

// User updated
//
UserShowViewController.prototype.userUpdated = function(data) {
  var response = jQuery.parseJSON(jQuery.parseJSON(data));

  if(response['status'] == 'success') {
    $(kUserBylineText).html($(kUserByline).val());
    $(kUserByline).hide();
    $(kUserUpdate).hide();
    $(kUserBylineText).show();
    $(kUserEdit).show();
  }
  else {
    this.userError(undefined,undefined,undefined);
  }
  
}

// Error creating comment
//
UserShowViewController.prototype.userError = function(r,s,e) {
  alert("An error occured, please try again");
  $(kUserByline).focus();
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// UI element event handlers
//-----------------------------------------------------------------------------

// Fired when a key presses in the user byline text field
//
UserShowViewController.prototype.userBylineKeyPressed = function(e) {
  if(e.keyCode == 13) {
    //this.updateUser();
    return false;
  }
}

// Fired when the user wants to create a byline
//
UserShowViewController.prototype.userEditInitiateClicked = function(e) {
  $(kUserEditInitiate).hide();
  $(kUserByline).show();
  $(kUserUpdate).show();
  $(kUserByline).focus();
}

// Fired whe the user wants to edit a byline
//
UserShowViewController.prototype.userEditClicked = function(e) {
  $(kUserBylineText).hide();
  $(kUserEdit).hide();
  $(kUserByline).show();
  $(kUserUpdate).show();
  $(kUserByline).focus();
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Analytics helpers
//-----------------------------------------------------------------------------

