// Partial to apply store auto complete functionaility to an element
//
Denwen.Partials.Stores.Autocomplete = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.stores = new Denwen.Collections.Stores();
    this.stores.fetch({
          data      : {filter: 'all'},
          success   : function(collection){self.autocomplete();},
          error     : function(collection,errors){}});
  },

  // Apply autocomplete funcitonality after the stores have been fetched
  //
  autocomplete: function() {
    this.trigger(Denwen.Callback.StoresLoaded,this.stores);

    this.el.typeahead({
              source:this.stores.pluck('name'),
              items: 50,
              matcher: function(item){
                return ~item.toLowerCase().replace(/[^\w]/g,'').
                          indexOf(this.query.toLowerCase().
                                        replace(/[^\w]/g,''));}});
  }
});
