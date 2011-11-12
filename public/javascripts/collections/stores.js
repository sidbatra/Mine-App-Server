// Collection of Store models 
//
Denwen.Stores = Backbone.Collection.extend({

  // Model Name
  //
  model: Denwen.Models.Store,

  // Constructor logic
  //
  initialize: function(models,options) {
    this.isAdmin = options['is_admin'];
  },

  // Custom url logic
  //
  url: function() {
    var url = '/stores';

    if(this.isAdmin)
      url = '/admin/stores';

    return url;
  }

});
