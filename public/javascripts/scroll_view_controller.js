// ScrollViewController abstracts scroll related events and methods
//

// Constructor Logic
//
function ScrollViewController() {

  var svController          = this;
  
  this.scrollEndedCallback  = null;
  this.resizeEndedCallback  = null;
  this.resizeTimerID        = null;
  
  $(window).scroll(function(){svController.scroll();});
  $(window).resize(function(){svController.resize();});
}

// Fired when the window scrolls 
//
ScrollViewController.prototype.scroll = function() {

 if ($(window).scrollTop() >= $(document).height() - $(window).height() - 200 &&
      this.scrollEndedCallback != null) {

      this.scrollEndedCallback();
   }
}

// Fired when the window resizes
//
ScrollViewController.prototype.resize = function() {

  if(this.resizeTimerID != null)
    clearTimeout(this.resizeTimerID);
  
  var svController    = this;
  this.resizeTimerID  = setTimeout(function(){svController.resizeEnded();},750);
}

// Fired when the window resizing ends
//
ScrollViewController.prototype.resizeEnded = function() {
  if(this.resizeEndedCallback != null)
    this.resizeEndedCallback();
}

// Tests whether the document has filled the window or not
//
ScrollViewController.prototype.isDocumentFillingWindow = function() {
  
  var fillStatus = true;

  if($(window).height() >= $(document).height())
    fillStatus = false;

  return fillStatus;
}

