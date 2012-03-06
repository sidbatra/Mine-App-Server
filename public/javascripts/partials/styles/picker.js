// Partial for a single style picker
//
Denwen.Partials.Styles.Picker = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self      = this;

    this.picked   = false;
    this.toggleEl = '#style_picker_' + this.model.get('id');

    $(this.toggleEl).click(function(){self.clicked();});
  },

  // Fired when the style is clicked to select/unselect 
  //
  clicked: function() {
    this.picked = !this.picked;

    if(this.picked) {
      //$(this.onEl).addClass('pushed');
      this.trigger('stylePicked',this.model.get('caption'));
    }
    else {
      //$(this.onEl).removeClass('pushed');
      this.trigger('styleUnpicked',this.model.get('caption'));
    }
  }

});
