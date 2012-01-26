// Collection of Store models 
//
Denwen.Collections.Stores = Backbone.Collection.extend({

  // Model Name
  //
  model: Denwen.Models.Store,

  // Constructor logic
  //
  initialize: function(models,options) {
    if(options != undefined)
      this.isAdmin = options['is_admin'];
    else
      this.isAdmin = false;
  },

  // Custom url logic
  //
  url: function() {
    var url = '/stores';

    if(this.isAdmin)
      url = '/admin/stores';

    return url;
  },

  // Comparator function for sorting alphabetically
  //
  comparator: function(store) {
    return store.get('name').toLowerCase();
  }

});
