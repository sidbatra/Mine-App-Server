// Store global configuration variables and manage the flow of the
// application
// 

// App wide constants
//

// Global variables
//
var itemsStore      = new Array();
var isDeviceMobile  = false;
var isDeviceiOS     = false;
var isDeviceiPad    = false;
var isDeviceiPhone  = false;
var deviceName      = '';

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
  try { console.log(s) } catch (e) {  }
};

// Conditionally replace and add default text
// in the given input field
//
function make_conditional_field(id,text,placeholderColor,textColor) {

  $(id).focus(function() { 
    if(this.value == text)
      this.value = '';
    else
      this.value = this.value;

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
function center_based_on_element(elementID) {
  var min = 150;

  $(document).ready(function() { 
    $(elementID).css('top',
      Math.max(min,($(window).height() - $(elementID).height())/2));
  });

  var scrollController = new ScrollViewController();
  scrollController.resizeEndedCallback  = function(){ 
    $(elementID).css('top',
      Math.max(min,($(window).height() - $(elementID).height())/2));
  }
}
