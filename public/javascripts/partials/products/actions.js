// Partial to load, display and create actions for a product
//
Denwen.Partials.Products.Actions = Backbone.View.extend({

  //Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self        = this;
    this.actionsEl  = $('#comments');
    this.productID  = this.options.product_id;

    this.likes      = false;
    this.owns       = false;
    this.wants      = false;

    this.actions  = new Denwen.Collections.Actions();
    this.actions.fetch({
          data    : {product_id:this.productID},
          success : function(){self.render();},
          error   : function(){}});
  },

  // Render the actions collection
  //
  render: function() {
    var self = this;

    this.actions.each(function(action){
      $(self.actionsEl).prepend(Denwen.JST['actions/action']({
                                      action:action}));
    });
  }
});
