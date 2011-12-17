// Partial for a single product picker
//
Denwen.Partials.Products.Picker = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.picked   = false;
    this.toggleEl = '#product_picker_' + this.model.get('id');
    this.onEl			= '#button_picker_' + this.model.get('id');

    this.render();
  },

  // Override render method for displaying view
  //
  render: function() {
    var self = this;

    this.el.append(Denwen.JST['products/product_picker']({product:this.model}));
    $(this.toggleEl).click(function(){self.clicked();});
  },

  // Fired when the product is clicked to turn on or off
  //
  clicked: function() {
    this.picked = this.picked ? false : true;

    if(this.picked) {
      $(this.onEl).addClass('pushed');
      
      this.trigger('addToProductsPicked',this.model.get('id'));
      analytics.productTurnedOn();
    }
    else {
      $(this.onEl).removeClass('pushed');
      
      this.trigger('removeFromProductsPicked',this.model.get('id'));
      analytics.productTurnedOff();
    }
  }

});
