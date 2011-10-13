// ProductShowViewController provides a javascript interface for
// displaying a product

// UI elements
var kCommentData    = '#comment_data';
var kCommentPost    = '#comment_post';
var kCommentsBox    = '#comments';

// Constructor logic
//
function ProductShowViewController(product_id) {
  var psvController     = this;
  this.product_id       = product_id;
  this.defCommentData   = $(kCommentData).val();

  make_conditional_field(
    kCommentData,
    this.defCommentData,
    $(this.defCommentData).css('color'),
    '#333333');

  restrictFieldSize($(kCommentData),254,'charsremain');

  $(kCommentData).keypress(function(e) { 
                        return psvController.commentDataKeyPressed(e); });

  $(kCommentPost).click(function() { psvController.createComment();});
}

// Share the product to social networks
//
ProductShowViewController.prototype.share = function() {
  $.ajax({
    type:       "POST",
    url:        "/share.js?product_id=" + this.product_id,
    success:    function(d){trace(d);},
    error:      function(r,s,e){trace(r + ' ' + s + ' ' + e);}
    });

  mpq.track("Save and Share it!");
}

// Create a comment
//
ProductShowViewController.prototype.createComment = function() {
  
  if($(kCommentData).val().length < 1 || 
      $(kCommentData).val() == this.defCommentData)  {

      alert("Please enter a valid comment");
      return;
  }

  var psvController = this;

  $.ajax({
    type:       "POST",
    url:        "/comments.js?comment[product_id]=" + this.product_id + 
                "&comment[data]=" + $(kCommentData).val(),
    success:    function(d){psvController.commentCreated(d);},
    error:      function(r,s,e){psvController.commentError(r,s,e);}
    });

  mpq.track("Comment Created");
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Ajax event handlers
//-----------------------------------------------------------------------------

//Comment created
//
ProductShowViewController.prototype.commentCreated = function(data) {
  var response = jQuery.parseJSON(jQuery.parseJSON(data));

  if(response['status'] == 'success') {
    $(kCommentsBox).prepend(response['body']['comment']);
    $(kCommentData).val('');
    $(kCommentData).focus();
  }
  else {
    this.commentError(undefined,undefined,undefined);
  }
  
}

// Error creating comment
//
ProductShowViewController.prototype.commentError = function(r,s,e) {
  alert("Error posting comment");
  $(kCommentData).focus();
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// UI element event handlers
//-----------------------------------------------------------------------------

ProductShowViewController.prototype.commentDataKeyPressed = function(e) {
  if(e.keyCode == 13) {
    this.createComment();
    return false;
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Analytics helpers
//-----------------------------------------------------------------------------

//Setup analytics for logged out state
//
ProductShowViewController.prototype.setupLoggedOutAnalytics = function() {
  mpq.track_links($("#action_link"),"FB Connect");
}

//Setup analytics for logged in state
//
ProductShowViewController.prototype.setupLoggedInAnalytics = function() {
  mpq.track_links($("#action_link"),"Share your own item");
}

//Setup analytics for post creation page
//
ProductShowViewController.prototype.setupPostCreationAnalytics = function() { 
  mpq.track_links($("#action_link"),"Done! Post Another");
}
