// View for modifying the user byline
//
Denwen.Partials.Users.Byline = Backbone.View.extend({

  // Event listeners
  //
  events: {
    "click #user_edit"          : "edit",
    "click #user_update"        : "update",
    "click #user_cancel"        : "cancel"
  },

  // Constructor logic
  //
  initialize: function() {
    this.textEl     = '#user_byline_text';
    this.editEl     = '#user_edit';
    this.editBoxEl  = '#user_edit_box';
    this.updateEl   = '#user_update';
    this.cancelEl   = '#user_cancel';
    this.inputEl    = '#user_byline';

    restrictFieldSize($(this.inputEl),130,'charsremain');
    $(this.inputEl).placeholder();
  },

  // Called when the byline has been saved on the server
  //
  changed: function() {
    $(this.textEl).html(this.model.escape('byline'));

    this.wipe();
    Denwen.Track.action("Byline Editing Completed");
  },

  // Called when the user wants to edit the byline
  //
  edit: function() {
    $(this.textEl).hide();
    $(this.editEl).hide();
    $(this.editBoxEl).hide();
    $(this.updateEl).show();
    $(this.cancelEl).show();
    $(this.inputEl).show();
    $(this.inputEl).focus();

    Denwen.Track.action("Byline Editing Initiated");
  },

  // User cancel's byline editing
  //
  cancel: function() {
    this.wipe();
    Denwen.Track.action("Byline Editing Cancelled");
  },

  // Hides the active editing UI
  //
  wipe: function() {
    $(this.cancelEl).hide();

    if(this.model.get('byline') == '' || 
        this.model.get('byline') == null) {

      $(this.inputEl).show();
      $(this.updateEl).show();
    }
    else {
      $(this.inputEl).hide();
      $(this.updateEl).hide();
      $(this.textEl).show();
      $(this.editEl).show();
      $(this.editBoxEl).show();
    }
  },

  // Called to save the new byline
  //
  update: function() {

    var self = this;

    if($(this.inputEl).val() == $(this.inputEl).attr('placeholder'))
      return;

    this.model.save(
      {'byline':$(this.inputEl).val()},
      { 
        success : function() {self.changed();},
        error   : function(model,errors) {}
      });
  }

});


