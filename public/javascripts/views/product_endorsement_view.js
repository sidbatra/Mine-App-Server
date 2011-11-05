// View for modifying the product endorsement
//
Denwen.ProductEndorsementView = Backbone.View.extend({


  // Event listeners
  //
  events: {
    "click #product_edit"          : "edit",
    "click #product_edit_initiate" : "edit",
    "click #product_update"        : "update",
    "click #product_cancel"        : "cancel"
  },

  initialize: function() {
    this.textEl     = '#product_endorsement_text';
    this.editEl     = '#product_edit';
    this.startEl    = '#product_edit_initiate';
    this.inputEl    = '#product_endorsement';
    this.updateEl   = '#product_update';
    this.cancelEl   = '#product_cancel';
  },

  // Called when the endorsement has been saved on the server
  //
  changed: function() {
    $(this.textEl).html(this.model.escape('endorsement'));

    this.wipe();
    analytics.endorsementEditingCompleted();
  },

  // Called when the user wants to edit the endorsement
  //
  edit: function() {
    $(this.startEl).hide();
    $(this.textEl).hide();
    $(this.editEl).hide();
    $(this.updateEl).show();
    $(this.cancelEl).show();
    $(this.inputEl).show();
    $(this.inputEl).focus();

    analytics.endorsementEditingSelected();
  },

  // User cancel's endorsement editing
  //
  cancel: function() {
    this.wipe();
    analytics.endorsementEditingCancelled();
  },

  // Hides the active editing UI
  //
  wipe: function() {
    $(this.updateEl).hide();
    $(this.cancelEl).hide();
    $(this.inputEl).hide();

    if(this.model.get('endorsement') == '' || 
        this.model.get('endorsement') == null) {
      $(this.startEl).show();
    }
    else {
      $(this.textEl).show();
      $(this.editEl).show();
    }
  },

  // Called to save the new endorsement
  //
  update: function() {

    var self = this;

    this.model.save(
      {'endorsement':$(this.inputEl).val()},
      { 
        success : function() {self.changed();},
        error   : function(model,errors) {}
      });
  }

});
