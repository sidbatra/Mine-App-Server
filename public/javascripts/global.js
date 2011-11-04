// Store global configuration variables and manage the flow of the
// application
// 

// App wide constants
//

// Global variables
//
var analytics       = new Denwen.Analytics();
var isDeviceMobile  = false;
var isDeviceiOS     = false;
var isDeviceiPad    = false;
var isDeviceiPhone  = false;
var deviceName      = '';

// Required to bypass rails CSRF protection, works in conjuction with
// the csrf_meta_tag helper in head section
//
$.ajaxSetup({
  beforeSend: function(xhr) {
    xhr.setRequestHeader(
          'X-CSRF-Token', 
          $('meta[name="csrf-token"]').attr('content'));
  }
}); 

// Setup device related global variables
//
function setupDeviceVariables(isMobile,isiPad,isiPhone) {
  isDeviceMobile    = isMobile;
  isDeviceiPad      = isiPad;
  isDeviceiPhone    = isiPhone;
  isDeviceiOS       = isiPad || isiPhone;
}

// Cross browser replacement of console.log
//
function trace(s) {
  //try { console.log(s) } catch (e) {  }
};

// Extra code to get IE compatability
//
function make_ie_compatible() {
  //Backbone.js gives an error unless json2 is loaded in ie7
  if($.browser.msie && parseInt($.browser.version,10) < 8) {
    $.getScript('http://ajax.cdnjs.com/ajax/libs/json2/20110223/json2.js');
  }
}

// Conditionally replace and add default text
// in the given input field
//
function make_conditional_field(id,text,placeholderColor,textColor) {

  $(id).focus(function() { 
    if(this.value == text)
      this.value = '';
    else {
      //this.value = this.value;
      }

    this.style.color = textColor;
  });

  $(id).blur(function() {
    if(this.value == '') { 
      this.value = text;
      this.style.color = placeholderColor;
    }
  });
}

// Vertically align the page based on the elementID
//
function center_based_on_element(elementID,min) {
  var margin  = 170;

  $(document).ready(function() { 
    $(elementID).css('top',
      Math.max(min,(($(window).height() - $(elementID).height())/2) - margin));
  });


  var windowListener = new Denwen.WindowListener();
  windowListener.bind('resizeEnded',function(){
    $(elementID).css('top',
      Math.max(min,(($(window).height() - $(elementID).height())/2) - margin));
    });
}
