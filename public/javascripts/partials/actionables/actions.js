// Partial to load, display and create actions for
// either a actionable or a collection
//
Denwen.Partials.Actionables.Actions = Backbone.View.extend({

  //Setup event handlers
  //
  events: {
    "click #like_actionable" : "likeClicked",
    "click #own_actionable"  : "ownClicked",
    "click #want_actionable" : "wantClicked"
  },

  // Constructor logic
  //
  initialize: function() {
    var self              = this;

    this.ownBox           = null;
    this.actionableID     = this.options.actionable_id;
    this.actionableType   = this.options.actionable_type;
    this.actionableUserID = this.options.actionable_user_id;

    this.actionsEl        = $('#feed_items');
    this.likeEl           = '#like_actionable';
    this.ownEl            = '#own_actionable';
    this.wantEl           = '#want_actionable';

    this.checked          = {'like' : false,'own' : false, 'want' : false};

    this.actions          = new Denwen.Collections.Actions();
    this.actions.fetch({
          data    : { source_id   : this.actionableID,
                      source_type : this.actionableType},
          success : function(){self.render();},
          error   : function(){}});


    if(this.actionableType == 'product') {
      this.ownBox = new Denwen.Partials.Products.Own({
                                el            : $(this.ownEl),
                                product_id    : this.actionableID});

      this.ownBox.bind('ownCreated',this.ownCreated,this);
      this.ownBox.bind('ownCancelled',this.ownCancelled,this);
    }
  },

  // Render the actions collection
  //
  render: function() {
    var self          = this;
    var currentUserID = helpers.currentUserID();

    this.actions.each(function(action){

      if(action.get('user_id') == currentUserID) {
        $('#' + action.get('name') + '_actionable').addClass('pushed');
        self.checked[action.get('name')] = true;
      }

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
      {name:name,source_id:this.actionableID,source_type:this.actionableType},{
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
    if(this.checked['like'])
      return;

    this.createAction('like');
    this.checked['like'] = true;

    $(this.likeEl).addClass('pushed');

    analytics.likeCreated(
                this.actionableType, 
                this.actionableID,
                this.actionableID,
                this.actionableType,
                this.actionableUserID);
  },

  // Own action clicked
  //
  ownClicked: function() {
    if(this.checked['own'])
      return;

    this.checked['own'] = true;

    this.ownBox.display();

    $(this.ownEl).addClass('held');

    analytics.ownInitiated(
                this.actionableType,
                this.actionableID,
                this.actionableID);
  },

  // Callback from ownBox when an own is created
  //
  ownCreated: function() {
    $(this.ownEl).removeClass('held');
    $(this.ownEl).addClass('pushed');

    this.createAction('own');

    analytics.ownCreated(
                this.actionableType,
                this.actionableID,
                this.actionableID);
  },

  // Callback from ownBox when an own is cancelled
  //
  ownCancelled: function() {
    $(this.ownEl).removeClass('held');
    this.checked['own'] = false;

    analytics.ownCancelled(
                this.actionableType,
                this.actionableID,
                this.actionableID);
  },

  // Want action clicked
  //
  wantClicked: function() {
    if(this.checked['want'])
      return;

    this.createAction('want');
    this.checked['want'] = true;

    $(this.wantEl).addClass('pushed');

    analytics.wantCreated(
                this.actionableType,
                this.actionableID,
                this.actionableID);
  }
});
