// Manage user interactions on a rendered product preview
//
Denwen.Partials.Products.Product = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    var self        = this;

    this.source     = this.options.source;
    this.sourceID   = this.options.sourceID;
    this.ownBox     = null;

    this.owns       = false;
    this.wants      = false;

    this.ownEl      = '#own_product_' + this.model.get('id');
    this.wantEl     = '#want_product_' + this.model.get('id');

    $(this.ownEl).click(function(){self.ownClicked();});
    $(this.wantEl).click(function(){self.wantClicked();});


    this.ownBox = new Denwen.Partials.Products.Own({
                              el          : $(this.ownEl),
                              product_id  : this.model.get('id')});

    this.ownBox.bind('ownCreated',this.ownCreated,this);
    this.ownBox.bind('ownCancelled',this.ownCancelled,this);
  },

  // Create the action initiated by the user
  //
  createAction: function(name) {
    var action = new Denwen.Models.Action();
    action.save({
      name        : name,
      source_id   : this.model.get('id'),
      source_type : 'product'});
  },

  // Fired when the own button is clicked
  //
  ownClicked: function() {
    if(this.owns)
      return;
    
    this.owns = true;

    this.ownBox.display();
    $(this.ownEl).addClass('held');

    analytics.ownInitiated(
                this.source,
                this.sourceID,
                this.model.get('id'));
  },

  // Callback from ownBox when an own is created
  //
  ownCreated: function() {
    $(this.ownEl).removeClass('held');
    $(this.ownEl).removeClass('hover_shadow_light');
    $(this.ownEl).addClass('pushed');

    this.createAction('own');

    analytics.ownCreated(
                this.source,
                this.sourceID,
                this.model.get('id'));
  },

  // Callback from ownBox when an own is cancelled
  //
  ownCancelled: function() {
    $(this.ownEl).removeClass('held');
    this.owns = false;

    analytics.ownCancelled(
                this.source,
                this.sourceID,
                this.model.get('id'));
  },

  // Fired when the want button is clicked
  //
  wantClicked: function() {
    if(this.wants)
      return;
    
    $(this.wantEl).removeClass('hover_shadow_light');
    $(this.wantEl).addClass('pushed');

    this.createAction('want');
    this.wants = true;

    analytics.wantCreated(
                this.source,
                this.sourceID,
                this.model.get('id'));
  }

});
