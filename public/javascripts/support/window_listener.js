// WindowListener catches & packages events related to the
// DOM window and fires custom triggers
//
Denwen.WindowListener = Backbone.View.extend({

  // Setup event listeners on the window to catch events
  //
  initialize: function() {
    var self = this;

    this.element = this.options.element ? this.options.element : document;
    this.resizeTimer = null;

    $(window).scroll(function(){self.scroll();});
    $(window).resize(function(){self.resize();});
  },

  // Fired when scrolling begins
  //
  scroll: function() {
   if ($(window).scrollTop() >= $(this.element).height() - 
                                  $(window).height() - 400 &&
        $(this.element).is(":visible"))
      this.trigger(Denwen.WindowListener.Callback.DocumentScrolled);
  },

  // Fired when the window resizes
  //
  resize: function() {
    if(this.resizeTimer != null)
      clearTimeout(this.resizeTimer);
  
    var self = this;
    this.resizeTimer = setTimeout(function(){
                self.trigger(Denwen.WindowListener.Callback.ResizeEnded);},750);
  },

  // Tests if the document has filled the window completely
  //
  isWindowEmpty: function() {
    var state = false;

    if($(window).height() >= $(this.element).height() - 150)
      state = true;

    return state;
  }

});

// Define callbacks.
//
Denwen.WindowListener.Callback = {
  DocumentScrolled: 'documentScrolled',
  ResizeEnded: 'resizeEnded'
}
