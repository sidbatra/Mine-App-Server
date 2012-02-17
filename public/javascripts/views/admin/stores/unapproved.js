// View for editing/approving stores in the admin UI 
//
Denwen.Views.Admin.Stores.Unapproved = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self                = this;

    this.approvedStores     = this.options.approved_collection; 
    this.unapprovedStores   = this.options.unapproved_collection; 
    this.storeEditViews     = new Array();
      
    this.populateStoreEditViews();
    this.setAutocompleteDataSource();
  },

  // Initialize and populate all store edit views 
  //
  populateStoreEditViews: function() {
    var self = this;

    this.unapprovedStores.each(function(store){
        var storeEditView = new Denwen.Partials.Admin.Stores.Unapproved({model:store});

        storeEditView.bind('storeUpdated',self.storeUpdated,self);
        self.storeEditViews.push(storeEditView);
    });
  },

  // Sets the autocomplete data source for all 
  // store edit views
  //
  setAutocompleteDataSource: function() {
    var stores = this.approvedStores.map(function(store){
                                          return store.get("name");});
    stores.push('Unknown');

    for (i in this.storeEditViews)
      this.storeEditViews[i].setupAutocomplete(stores);
  },

  // Fired when a model within the collection has been updated
  //
  storeUpdated: function(store) {
    this.approvedStores.add(store);  
    this.setAutocompleteDataSource();
  }

});
