// Store global configuration variables and manage the flow of the
// application
// 

// Global variables
//
var analytics     = new Denwen.Analytics();
Denwen.A      = new Denwen.Analytics();
Denwen.H      = new Denwen.Helpers();
Denwen.Drawer = new Denwen.Partials.Common.MessageDrawer();
var dDrawer       = new Denwen.Partials.Common.MessageDrawer();


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

// Conditionally replace and add default text
// in the given input field
//
function make_conditional_field(id) {

  var el = $(id);
  var placeholder = el.attr('data-placeholder');
  var placeholderColor = el.attr('ui-placeholder-color');
  var textColor = el.attr('ui-text-color');

  if(el.val() == '') {
    el.val(placeholder);
    el.css('color',placeholderColor);
  }
  else {
    el.css('color',textColor);
  }

  el.focus(function() { 
    if(this.value == placeholder)
      this.value = '';

    this.style.color = textColor;
  });

  el.blur(function() {
    if(this.value == '') { 
      this.value = placeholder;
      this.style.color = placeholderColor;
    }
  });
}
