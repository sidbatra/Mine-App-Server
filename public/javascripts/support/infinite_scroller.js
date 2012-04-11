// InfiniteScroller tracks infinite scrolling events on the entire document
// or a provided element and fires callbacks on noteworthy events.
//
Denwen.InfiniteScroller = Backbone.View.extend({

  // Constructor Logic. Bind to event listeners on the DOM
  // to initiate infinite scrolling logic.
  //
  // element - String:document. ID of element which is to infinite scroll.
  // scrollMargin - Integer:400. Margin of scroll bar from the bottom to fire 
  //                  an event indicating the end has reached.
  // emptyMargin - Integer:150. Margin on the test of empitiness of the 
  //                document or element.
  //
  initialize: function() {
    var self = this;

    this.pageMode = true;
    this.element = document;
    this.resizeTimer = null;
    this.scrollMargin = this.options.scrollMargin ? 
                          this.options.scrollMargin : 
                          400;
    this.emptyMargin = this.options.emptyMargin ?
                        this.options.emptyMargin :
                        150;
    
    if(this.options.element) {
      this.element = this.options.element;
      this.pageMode = false;
    }

    if(this.pageMode)
      $(window).scroll(function(){self.pageScroll();});
    else 
      $(this.element).scroll(function(){self.elementScroll();});

    //$(window).resize(function(){self.resize();});
  },

  // Fired when the entire window scrolls. A callback is triggered
  // if the end of the page has been reached.
  //
  pageScroll: function() {
   if ($(window).scrollTop() >= $(document).height() -
                                  $(window).height() - this.scrollMargin)
      this.trigger(Denwen.InfiniteScroller.Callback.EndReached);
  },

  // Tests if the document has filled the window completely.
  //
  isPageEmpty: function() {
    return $(window).height() >= $(document).height() - this.emptyMargin;
  },

  // Fired when the provided element scrolls. A callback is triggered
  // if the end of the element has been reached.
  //
  elementScroll: function() {
   if ($(this.element).scrollTop() >= $(this.element)[0].scrollHeight -
                                  $(this.element).height() - this.scrollMargin)
      this.trigger(Denwen.InfiniteScroller.Callback.EndReached);
  },

  // Tests of the providede element has been filled to it's original height.
  //
  isElementEmpty: function() {
    return $(this.element).height() >= $(this.element)[0].scrollHeight - 
                                          this.emptyMargin;
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
Denwen.InfiniteScroller.Callback = {
  EndReached : 'endReached',
  ResizeEnded: 'resizeEnded'
}
