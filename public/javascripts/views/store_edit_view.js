// View for editing a store in the admin UI 
//
Denwen.StoreEditView = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self        = this;

    this.inputEl    = $('#store_name_' + this.model.id); 
    this.updateEl   = $('#store_update_' + this.model.id); 
    this.el         = $('#tr_' + this.model.id);

    this.updateEl.click(function(){self.update();});
  },

  // Adds autocomplete functionality to the 
  // store name text field
  //
  setupAutocomplete :function(stores) {
    this.inputEl.autocomplete(
                        stores,{
                        formatMatch: function(item){
                          return item[0].replace(/[^\w]/gi, '');},
                        formatResult: function(item){
                          return item[0];}
                        });
  },

  // Called when the store has been updated on the server 
  //
  changed: function() {
    this.trigger('storeUpdated',this.model);
    this.remove();
  },

  // Called when the admin tried to update a store 
  //
  update: function() {
   var self = this;

   this.model.save(
          {'name':this.inputEl.val()},
          {
            success : function(){self.changed();},
            error   : function(model,errors){}
          });
  }

});
