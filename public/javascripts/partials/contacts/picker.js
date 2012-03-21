// Partial for a single contact picker
//
Denwen.Partials.Contacts.Picker = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self      = this;

    this.picked   = false;
    this.toggleEl = '#contact_picker_' + this.model.get('id');

    $(this.toggleEl).click(function(){self.clicked();});
  },

  // Fired when the contact is clicked to select
  //
  clicked: function() {
    this.trigger('contactPicked',this);
  },

  // Change the state of the contact picker to selected 
  // 
  enable: function() {
    this.picked = true; 
    $(this.toggleEl).addClass('selected');
  },

  // Change the state of the contact picker to unselected 
  // 
  restore: function() {
    this.picked = false;
    $(this.toggleEl).removeClass('selected');
  }

});
