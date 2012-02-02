// View for selecting favourite stores
//
Denwen.Views.Shoppings.New = Backbone.View.extend({
  
  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self            = this;

    this.storesEl       = '#stores';
    this.formEl         = '#new_shopping';
    this.storeIdsEl     = '#store_ids';
    this.buttonEl       = '#stores_picked_button';

    this.posting        = false;

    this.storesPicked   = new Array(); 

    $(this.formEl).submit(function(){return self.post();});

    this.get();
    this.setAnalytics();
  },

  // Fetches the stores 
  //
  get: function() {
    var self        = this;
    this.stores     = new Denwen.Collections.Stores();

    this.stores.fetch({
          data    :  {filter: 'suggest'},
          success :  function(collection){self.fetched();},
          error   :  function(collection,errors){}
          });
  },

  // Fired when the stores json has been fetched from
  // the server
  //
  fetched: function(){
    var self = this;

    this.stores.comparator = function(store) { 
                              return store.get('name').toLowerCase();};

    this.stores.sort().each(function(store){

      var storePicker = new Denwen.Partials.Stores.Picker({
                                        model : store,
                                        el    : $(self.storesEl)
                                        });
      storePicker.bind(
        'addToStoresPicked',
        self.addToStoresPicked,
        self);

      storePicker.bind(
        'removeFromStoresPicked',
        self.removeFromStoresPicked,
        self);
    });
      
    $(this.formEl).show();
  },

  // Fired when a store is picked
  //
  addToStoresPicked: function(storeID) {
    this.storesPicked.push(storeID);

    if(this.storesPicked.length >= 3) { 
      $(this.buttonEl).removeClass('disactivated');
      $(this.buttonEl).removeAttr('disabled'); 
    }
    
    analytics.storePicked();
  },

  // Fired when a store is unpicked
  //
  removeFromStoresPicked: function(storeID) {
    this.storesPicked = _.without(this.storesPicked,storeID);

    if(this.storesPicked.length < 3) { 
      $(this.buttonEl).addClass('disactivated');
      $(this.buttonEl).attr('disabled',true); 
    }

    analytics.storeUnpicked();
  },

  // Form submitted callback
  //
  post: function() {

    if(this.posting)
      return false;

    this.posting  = true;
    $(this.storeIdsEl).val(this.storesPicked.join(","));

    return true;
  },

  // Fire tracking events
  //
  setAnalytics: function() {
    analytics.onboardingStoresView();
  }

});
