// WindowListener catches & packages events related to the
// DOM window and fires custom triggers
//
Denwen.WindowListener = Backbone.View.extend({

  // Setup event listeners on the window to catch events
  //
  initialize: function() {
    var self = this;

    this.pageMode = true;
    this.element = document;
    
    if(this.options.element) {
      this.element = this.options.element;
      this.pageMode = false;
    }

    this.resizeTimer = null;

    if(this.pageMode){
      $(window).scroll(function(){self.pageScroll();});
    }
    else {
      $(this.element).scroll(function(){self.elementScroll();});
    }
    //$(window).resize(function(){self.resize();});
  },

  // Fired when scrolling begins
  //
  pageScroll: function() {
   if ($(window).scrollTop() >= $(document).height() -
                                  $(window).height() - 400)
      this.trigger(Denwen.WindowListener.Callback.DocumentScrolled);
  },

  // Tests if the document has filled the window completely
  //
  isPageEmpty: function() {
    return $(window).height() >= $(document).height() - 150;
  },

  //
  elementScroll: function() {
   if ($(this.element).scrollTop() >= $(this.element)[0].scrollHeight -
                                  $(this.element).height() - 200)
      this.trigger(Denwen.WindowListener.Callback.DocumentScrolled);
  },

  isElementEmpty: function() {
    return $(this.element).height() >= $(this.element)[0].scrollHeight - 150;
  }

  // Fired when the window resizes
  //
  //resize: function() {
  //  if(this.resizeTimer != null)
  //    clearTimeout(this.resizeTimer);
  //
  //  var self = this;
  //  this.resizeTimer = setTimeout(function(){
  //              self.trigger(Denwen.WindowListener.Callback.ResizeEnded);},750);
  //},

});

// Define callbacks.
//
Denwen.WindowListener.Callback = {
  DocumentScrolled: 'documentScrolled',
  ResizeEnded: 'resizeEnded'
}
