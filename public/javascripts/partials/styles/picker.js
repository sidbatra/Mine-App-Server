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

  // Fired when the style is clicked to select
  //
  clicked: function() {
    this.picked = true; 

    $(this.toggleEl).addClass('selected');
    this.trigger('stylePicked',this.model);
  },

  // Change the state of the style picker to unselected 
  // 
  disable: function() {
    this.picked = false;

    $(this.toggleEl).removeClass('selected');
  }

});
