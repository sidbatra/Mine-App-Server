// WindowListener catches & packages events related to the
// DOM window and fires custom triggers
//
Denwen.WindowListener = Backbone.View.extend({

  // Setup event listeners on the window to catch events
  //
  initialize: function() {
    var self = this;

    this.resizeTimer = null;
  
    $(window).scroll(function(){self.scroll();});
    $(window).resize(function(){self.resize();});
  },

  // Fired when scrolling begins
  //
  scroll: function() {
   if ($(window).scrollTop() >= $(document).height() - 
                                  $(window).height() - 200)
        this.trigger('documentScrolled');
  },

  // Fired when the window resizes
  //
  resize: function() {
    if(this.resizeTimer != null)
      clearTimeout(this.resizeTimer);
  
    var self = this;
    this.resizeTimer = setTimeout(function(){self.trigger('resizeEnded');},750);
  },

  // Tests if the document has filled the window completely
  //
  isWindowEmpty: function() {
    var state = false;

    if($(window).height() >= $(document).height())
      state = true;

    return state;
  }

});
