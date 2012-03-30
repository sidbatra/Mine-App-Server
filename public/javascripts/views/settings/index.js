// Edit settings
//
Denwen.Views.Settings.Index = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.updated = this.options.updated;
    this.source = this.options.source;

    // Attach listeners on to setting checkboex
    //
    _.each(this.el.find('input'),function(input){
      if(input.type == 'checkbox')
        $('#' + input.id).change(function(){self.settingToggled(this)});
    });

    if(this.updated == 'true')
      Denwen.Drawer.success("Your changes have been saved.");
    else if(this.updated == 'false')
      Denwen.Drawer.error("Sorry, there was an error saving your changes.");

    this.setAnalytics();
  },

  // Fired when a setting check box is toggled
  //
  settingToggled: function(checkBox) {
    var name = checkBox.id.slice(8,checkBox.id.length);

    if($('#' + checkBox.id).is(':checked'))
      Denwen.Track.settingTurnedOn(name);
    else
      Denwen.Track.settingTurnedOff(name);
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    Denwen.Track.settingsView(this.source);

    if(this.source == 'saved')
      Denwen.Track.settingsUpdated();

    if(this.source.slice(0,6) == 'email_')
      Denwen.Track.unsubscribeInitiated(this.source.slice(6,this.source.length));
  }

});

