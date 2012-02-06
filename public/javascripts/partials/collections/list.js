// Partial to load and display a user's collections
//
Denwen.Partials.Collections.List = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.ownerID      = this.options.ownerID;
    this.source       = this.options.source;
    this.filter       = this.options.filter;
    this.productsLeft = this.options.productsLeft;
    this.collections  = new Denwen.Collections.Collections();
  },

  // Fetch the user's collections
  //
  fetch: function() {
    var self = this;

    this.collections.fetch({
          data      : {filter: self.filter,owner_id: self.ownerID},
          success   : function(collection){
                        self.trigger(Denwen.Callback.CollectionsListLoaded);
                        self.render();},
          error     : function(collection,errors){}
    });
  },

  // Render user's collections
  //
  render: function() {
    var self = this;

    $(this.el).html(
      Denwen.JST['collections/list']({
        collections   : this.collections,
        ownerID       : this.ownerID,
        productsLeft  : this.productsLeft}));
    
    this.collections.each(function(collection){
      new Denwen.Partials.Collections.Collection({
            model     : collection,
            source    : self.source,
            sourceID  : self.ownerID});
    });
  }


});
