// UserShowViewController provides a javascript interface for
// displaying a user

// UI elements
var kUserByline     = '#user_byline';
var kUserEdit       = '#user_edit';


// Constructor logic
//
function UserShowViewController(user_id) {
  var usvController     = this;
  this.user_id          = user_id;

  restrictFieldSize($(kUserByline),140,'charsremain');

  $(kUserByline).keypress(function(e) { 
                        return usvController.userBylineKeyPressed(e); });

  $(kUserEdit).click(function() { });
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
    $(kUserByline).hide();
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

UserShowViewController.prototype.userBylineKeyPressed = function(e) {
  if(e.keyCode == 13) {
    this.updateUser();
    return false;
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Analytics helpers
//-----------------------------------------------------------------------------

