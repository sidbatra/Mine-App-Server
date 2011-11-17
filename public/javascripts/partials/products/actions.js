// Partial to load, display and create actions for a product
//
Denwen.Partials.Products.Actions = Backbone.View.extend({

  //Setup event handlers
  //
  events: {
    "click #like_product" : "likeClicked",
    "click #own_product"  : "ownClicked",
    "click #want_product" : "wantClicked"
  },

  // Constructor logic
  //
  initialize: function() {
    var self            = this;
    this.actionsEl      = $('#feed_items');
    this.productID      = this.options.product_id;
    this.productUserID  = this.options.product_user_id;

    this.likeEl         = '#like_product';
    this.ownEl          = '#own_product';
    this.wantEl         = '#want_product';

    this.likes          = false;
    this.owns           = false;
    this.wants          = false;

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
      $(self.actionsEl).append(Denwen.JST['actions/action']({
                                      action:action}));
    });
  },

  // Create an action
  //
  createAction: function(name){
    var self    = this;
    var action  = new Denwen.Models.Action();

    this.actions.add(action);

    action.save(
        {name:name,product_id:this.productID},{
        success : function(model) { self.created(model);},
        error   : function(model,errors) {}});
  },

  // Fired when a new action is created
  //
  created: function(action) {
    $(this.actionsEl).prepend(Denwen.JST['actions/action']({
                                    action:action}));
  },

  // Like action clicked
  //
  likeClicked: function() {
    if(this.likes)
      return;

    this.createAction('like');
    this.likes = true;

    $(this.likeEl).addClass('pushed');

    analytics.likeCreated(
                'product',
                this.productID,
                this.productID,
                this.productUserID);
  },

  // Own action clicked
  //
  ownClicked: function() {
    if(this.owns)
      return;

    this.createAction('own');
    this.owns = true;

    $(this.ownEl).addClass('pushed');

    analytics.ownCreated(
                'product',
                this.productID,
                this.productID);
  },

  // Want action clicked
  //
  wantClicked: function() {
    if(this.wants)
      return;

    this.createAction('want');
    this.wants = true;

    $(this.wantEl).addClass('pushed');

    analytics.wantCreated(
                'product',
                this.productID,
                this.productID);
  }
});
