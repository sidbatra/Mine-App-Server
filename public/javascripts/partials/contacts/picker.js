// Partial for a single contact picker
//
Denwen.Partials.Contacts.Picker = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self      = this;
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
    $(this.toggleEl).addClass('selected');
    $(this.toggleEl).removeClass('disabled');
  },

  // Change the state of the contact picker to unselected 
  // 
  disable: function() {
    $(this.toggleEl).removeClass('selected');
    $(this.toggleEl).addClass('disabled');
  }

});
