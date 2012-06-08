// Display info, error and success messages across the app
//
Denwen.Partials.Common.MessageDrawer = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.successClass = 'alert-success';
    this.errorClass   = 'alert-error';
    this.infoClass    = 'alert-info';

    this.messengerEl  = $('#message-drawer');
    $(this.messengerEl).bind('closed',function(){self.drawerClosed()});
  },

  // Display a new message with a new class in the drawer
  //
  display: function(text,newClass,timeout) {
    var self = this;

    if(timeout == undefined)
      timeout = 5000;

    if(!timeout)
      text = "<div>" + "<a class='close' data-dismiss='alert'>×</a>" + 
        text + "</div>";

    this.messengerEl.removeClass(this.successClass);
    this.messengerEl.removeClass(this.errorClass);
    this.messengerEl.removeClass(this.infoClass);

    this.messengerEl.addClass(newClass);
    this.messengerEl.html(text);

    this.messengerEl.fadeIn();

    if(timeout)
      setTimeout(function(){self.messengerEl.fadeOut();},timeout);
  },

  // Fired when the user closes the drawer.
  //
  drawerClosed: function() {
    this.messengerEl.hide();
  },

  // Display a success message
  //
  success: function(text,timeout) {
    this.display(text,this.successClass,timeout);
  },

  // Display an error message
  //
  error: function(text,timeout) {
    this.display(text,this.errorClass,timeout);
  },

  // Display an info message
  //
  info: function(text,timeout) {
    this.display(text,this.infoClass,timeout);
  },

  // Display a plain message
  //
  message: function(text,timeout) {
    this.display(text,'',timeout);
  }

});

