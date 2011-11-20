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
    this.el.autocomplete(
              this.stores.pluck('name'),{
               formatMatch: function(item){
                return item[0].replace(/[^\w]/gi, '');},
               formatResult: function(item){
                return item[0];} });
  }
});
