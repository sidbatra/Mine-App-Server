// View for modifying the user byline
//
Denwen.UserBylineView = Backbone.View.extend({

  // Event listeners
  //
  events: {
    "click #user_edit"          : "edit",
    "click #user_edit_initiate" : "edit",
    "click #user_update"        : "update"
  },

  // Constructor logic
  //
  initialize: function() {
    this.textEl     = '#user_byline_text';
    this.editEl     = '#user_edit';
    this.startEl    = '#user_edit_initiate';
    this.updateEl   = '#user_update';
    this.inputEl    = '#user_byline';

    restrictFieldSize($(this.inputEl),254,'charsremain');
  },

  // Called when the byline has been saved on the server
  //
  changed: function() {
    $(this.textEl).html(this.model.escape('byline'));
    $(this.updateEl).hide();
    $(this.inputEl).hide();
    $(this.textEl).show();
    $(this.editEl).show();
  },

  // Called when the user wants to edit the byline
  //
  edit: function() {
    $(this.startEl).hide();
    $(this.textEl).hide();
    $(this.editEl).hide();
    $(this.updateEl).show();
    $(this.inputEl).show();
    $(this.inputEl).focus();
  },

  // Called to save the new byline
  //
  update: function() {

    var self = this;

    this.model.save(
      {'byline':$(this.inputEl).val()},
      { 
        success: function() {self.changed();},
        error : function(model,errors) {},
      });
  },

});


