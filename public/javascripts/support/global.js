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
