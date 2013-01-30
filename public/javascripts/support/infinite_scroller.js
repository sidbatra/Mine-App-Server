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
    this.fixedTestElement = this.options.fixedTestElement;
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

    $(window).resize(function(){self.resize();});
  },

  // Fired when the entire window scrolls. A callback is triggered
  // if the end of the page has been reached.
  //
  pageScroll: function() {
   if (!this.isFixed() && $(window).scrollTop() >= $(document).height() -
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
   if (!this.isFixed() && $(this.element).scrollTop() >= $(this.element)[0].scrollHeight -
                                  $(this.element).height() - this.scrollMargin)
      this.trigger(Denwen.InfiniteScroller.Callback.EndReached);
  },

  // Tests of the provided element has been filled to it's original height.
  //
  isElementEmpty: function() {
    return $(this.element).height() >= $(this.element)[0].scrollHeight - 
                                          this.emptyMargin;
  },

  // Fired when the window resizes. Initiate an empty space test.
  //
  resize: function() {
    if(this.resizeTimer != null)
      clearTimeout(this.resizeTimer);
  
    var self = this;
    this.resizeTimer = setTimeout(function(){
                self.emptySpaceTest();},
                750);
  },

  // Tests if the scrollable element has empty space left.
  //
  emptySpaceTest: function() {
    if(!this.isFixed() && (this.pageMode ? this.isPageEmpty() : this.isElementEmpty()))
      this.trigger(Denwen.InfiniteScroller.Callback.EmptySpaceFound);
  },

  // Avoid firing triggers if the page has gone into
  // a fixed mode i.e. when a primary div on the page has been
  // fixed and pagination is to cease.
  //
  isFixed: function() {
    return this.fixedTestElement && this.fixedTestElement.css('position') == 'fixed';
  }

});

// Define callbacks.
//
Denwen.InfiniteScroller.Callback = {
  EndReached: 'endReached',
  EmptySpaceFound: 'emptySpaceFound'
}
