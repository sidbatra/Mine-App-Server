// Store global configuration variables and manage the flow of the
// application
// 

// Global variables
//
Denwen.Track  = new Denwen.Analytics();
Denwen.H      = new Denwen.Helpers();
Denwen.NM     = new Denwen.NotificationManager();
Denwen.Drawer = new Denwen.Partials.Common.MessageDrawer();


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

// Ensure IE 7 compatability with Backbone.js via json2
//
function make_ie_compatible() {
  if($.browser.msie && parseInt($.browser.version,10) < 8) {
    $.getScript('http://ajax.cdnjs.com/ajax/libs/json2/20110223/json2.js');
  }
}
