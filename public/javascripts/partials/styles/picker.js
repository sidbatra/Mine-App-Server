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
    this.toggleEl = '#style_picker_' + this.model.get('id');

    $(this.toggleEl).click(function(){self.clicked();});
  },

  // Fired when the style is clicked to select
  //
  clicked: function() {
    this.trigger('stylePicked',this.model.get('id'));
  },

  // Change the state of the style picker to selected 
  // 
  enable: function() {
    $(this.toggleEl).addClass('selected');
    $(this.toggleEl).removeClass('disabled');
  },

  // Change the state of the style picker to unselected 
  // 
  disable: function() {
    $(this.toggleEl).removeClass('selected');
    $(this.toggleEl).addClass('disabled');
  }

});
