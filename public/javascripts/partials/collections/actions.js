// Partial to load, display and create actions for a collection 
//
Denwen.Partials.Collections.Actions = Backbone.View.extend({

  //Setup event handlers
  //
  events: {
    "click #like_collection" : "likeClicked",
  },

  // Constructor logic
  //
  initialize: function() {
    var self              = this;

    this.actionsEl        = $('#feed_items');
    this.collectionID     = this.options.collection_id;
    this.collectionUserID = this.options.collection_user_id;

    this.likeEl           = '#like_collection';

    this.checked          = {'like' : false};

    this.actions          = new Denwen.Collections.Actions();
    this.actions.fetch({
          data    : {source_id:this.collectionID,source_type:'collection'},
          success : function(){self.render();},
          error   : function(){}});
  },

  // Render the actions collection
  //
  render: function() {
    var self          = this;
    var currentUserID = helpers.currentUserID();

    this.actions.each(function(action){

      if(action.get('user_id') == currentUserID) {
        $('#' + action.get('name') + '_collection').addClass('pushed');
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
        {name:name,source_id:this.collectionID,source_type:'collection'},{
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

   /* analytics.likeCreated(
                'collection',
                this.collectionID,
                this.collectionID,
                this.collectionUserID);*/
  }

});
