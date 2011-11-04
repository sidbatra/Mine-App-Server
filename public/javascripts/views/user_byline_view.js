// View for modifying the user byline
//
Denwen.UserBylineView = Backbone.View.extend({

  // Event listeners
  //
  events: {
    "click #user_edit"          : "edit",
    "click #user_edit_initiate" : "edit",
    "click #user_update"        : "update",
    "click #user_cancel"        : "cancel"
  },

  // Constructor logic
  //
  initialize: function() {
    this.textEl     = '#user_byline_text';
    this.editEl     = '#user_edit';
    this.startEl    = '#user_edit_initiate';
    this.updateEl   = '#user_update';
    this.cancelEl   = '#user_cancel';
    this.inputEl    = '#user_byline';

    restrictFieldSize($(this.inputEl),254,'charsremain');
  },

  // Called when the byline has been saved on the server
  //
  changed: function() {
    $(this.textEl).html(this.model.escape('byline'));
    $(this.updateEl).hide();
    $(this.cancelEl).hide();
    $(this.inputEl).hide();
    $(this.textEl).show();
    $(this.editEl).show();

    analytics.bylineEditingCompleted();
  },

  // Called when the user wants to edit the byline
  //
  edit: function() {
    $(this.startEl).hide();
    $(this.textEl).hide();
    $(this.editEl).hide();
    $(this.updateEl).show();
    $(this.cancelEl).show();
    $(this.inputEl).show();
    $(this.inputEl).focus();

    analytics.bylineEditingSelected();
  },

  // User cancel's byline editing
  //
  cancel: function() {
    $(this.updateEl).hide();
    $(this.cancelEl).hide();
    $(this.inputEl).hide();

    if(this.model.get('byline') == '') {
      $(this.startEl).show();
    }
    else {
      $(this.textEl).show();
      $(this.editEl).show();
    }

    analytics.bylineEditingCancelled();
  },

  // Called to save the new byline
  //
  update: function() {

    var self = this;

    this.model.save(
      {'byline':$(this.inputEl).val()},
      { 
        success : function() {self.changed();},
        error   : function(model,errors) {}
      });
  }

});


