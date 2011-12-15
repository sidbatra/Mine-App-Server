// Manage user interactions on a rendered product
//
Denwen.Partials.Products.Product = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    var self        = this;

    this.onboarding = this.options.onboarding;
    this.onMode     = this.options.onMode;
    this.source     = this.options.source;
    this.sourceID   = this.options.sourceID;
    this.ownBox     = null;

    this.likes      = false;
    this.owns       = false;
    this.wants      = false;

    this.el         = $('#product_' + this.model.get('id'));
    this.onEl       = '#on_' + this.model.get('id');


    this.likeEl     = '#like_product_' + this.model.get('id');
    this.ownEl      = '#own_product_' + this.model.get('id');
    this.wantEl     = '#want_product_' + this.model.get('id');

    this.el.mouseenter(function(){self.onMouseEnter();});
    this.el.mouseleave(function(){self.onMouseLeave();});

    $(this.likeEl).click(function(){self.likeClicked();});
    $(this.ownEl).click(function(){self.ownClicked();});
    $(this.wantEl).click(function(){self.wantClicked();});


    this.ownBox = new Denwen.Partials.Products.Own({
                              el          : $(this.ownEl),
                              product_id  : this.model.get('id')});

    this.ownBox.bind('ownCreated',this.ownCreated,this);
    this.ownBox.bind('ownCancelled',this.ownCancelled,this);
  },

  // User enters the main product div
  //
  onMouseEnter: function() {
    if(!this.onMode)
      return;
    
    $(this.onEl).show();

    if(this.onboarding)
      console.log('Wow fancy onboarding');
  },

  // User exits the main product div
  //
  onMouseLeave: function() {
    if(!this.onMode)
      return;

    $(this.onEl).hide();

    if(this.onboarding)
      console.log('Do not leave');
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

  // Fired when the like button is clicked
  //
  likeClicked: function() {
    if(this.likes)
      return;
    
    $(this.likeEl).removeClass('hover_shadow_light');
    $(this.likeEl).addClass('pushed');

    this.createAction('like');
    this.likes = true;

    analytics.likeCreated(
                this.source,
                this.sourceID,
                this.model.get('id'),
                this.model.get('user_id'));
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
