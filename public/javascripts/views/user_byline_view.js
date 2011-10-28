Denwen.UserBylineView = Backbone.View.extend({

  events: {
    "click #user_edit": "edit",
    "click #user_edit_initiate": "edit",
    "click #user_update": "update"
  },

  initialize: function() {
    this.textEl     = '#user_byline_text';
    this.editEl     = '#user_edit';
    this.startEl    = '#user_edit_initiate';
    this.updateEl   = '#user_update';
    this.inputEl    = '#user_byline';

    restrictFieldSize($(this.inputEl),254,'charsremain');
  },

  changed: function() {
    $(this.textEl).html(this.model.escape('byline'));
    $(this.updateEl).hide();
    $(this.inputEl).hide();
    $(this.textEl).show();
    $(this.editEl).show();
  },

  edit: function() {
    $(this.startEl).hide();
    $(this.textEl).hide();
    $(this.editEl).hide();
    $(this.updateEl).show();
    $(this.inputEl).show();
    $(this.inputEl).focus();
  },

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


