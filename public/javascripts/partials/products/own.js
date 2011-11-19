// Display the UI for claiming ownership of a product 
//
Denwen.Partials.Products.Own  = Backbone.View.extend({

  // Event listeners
  //
  events: {
    "click #create_own" : "create",
    "click #cancel_own" : "cancel"
  },

  // Constructor logic
  //
  initialize: function() {
    this.productID  = this.options.product_id;
    this.boxEl      = '#own_box_' + this.productID;
    this.render();
  },

  // Display the UI for claiming ownership
  //
  render: function() {
    this.el.append(Denwen.JST['products/own']({
                                    id:this.productID}));
  },

  // Create ownership
  //
  create: function() {
    //$(this.boxEl).remove();
    //this.trigger('ownCreated');
  },

  // Cancel ownership creation
  //
  cancel: function() {
    $(this.boxEl).remove();
    this.trigger('ownCancelled');
  }

});
