// View for editing a store in the admin UI 
//
Denwen.AdminStoreView = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self        = this;

    this.id         = this.options.id;
    this.inputEl    = $('#store_name_' + this.id); 
    this.updateEl   = $('#store_update_' + this.id); 
    this.linkEl     = $('#store_link_' + this.id);

    this.updateEl.click(function(){self.update();});
  },

  // Called when the store has been updated on the server 
  //
  changed: function() {
    stores.push(this.model.get("name"));
    updateAutocomplete();
    this.wipe();
  },

  // Hides the store that has been edited
  //
  wipe: function() {
    this.inputEl.hide();
    this.updateEl.hide();
    this.linkEl.hide();
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
