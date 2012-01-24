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
    this.userID       = this.options.userID;
    this.collections  = new Denwen.Collections.Collections();
  },

  // Fetch the user's collections
  //
  fetch: function() {
    var self = this;

    this.collections.fetch({
          data      : {filter: 'user',owner_id: self.userID},
          success   : function(collection){self.render();},
          error     : function(collection,errors){}
    });
  },

  // Render user's collections
  //
  render: function() {
    $(this.el).html(
      Denwen.JST['collections/list']({
        collections : this.collections}));
  }


});
