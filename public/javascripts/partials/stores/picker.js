// Partial for a single store picker
//
Denwen.Partials.Stores.Picker = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.picked   = false;
    this.toggleEl = '#store_picker_' + this.model.get('id');

    this.render();
  },

  // Override render method for displaying view
  //
  render: function() {
    var self = this;

    this.el.append(Denwen.JST['stores/picker']({store:this.model}));
    $(this.toggleEl).click(function(){self.clicked();});
  },

  // Fired when the store is clicked to select/unselect 
  //
  clicked: function() {
    this.picked = !this.picked;

    if(this.picked) {
      $(this.toggleEl).addClass('selected');
      this.trigger('addToStoresPicked',this.model.get('id'));
    }
    else {
      $(this.toggleEl).removeClass('selected');
      this.trigger('removeFromStoresPicked',this.model.get('id'));
    }
  }

});
