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

function trace(s) {
  try { console.log(s) } catch (e) {  }
};

