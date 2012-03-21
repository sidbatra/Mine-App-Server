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
      dDrawer.success("Your changes have been saved.");
    else if(this.updated == 'false')
      dDrawer.error("Sorry, there was an error saving your changes.");

    this.setAnalytics();
  },

  // Fired when a setting check box is toggled
  //
  settingToggled: function(checkBox) {
    var name = checkBox.id.slice(8,checkBox.id.length);

    if($('#' + checkBox.id).is(':checked'))
      analytics.settingTurnedOn(name);
    else
      analytics.settingTurnedOff(name);
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    analytics.settingsView(this.source);

    if(this.source == 'saved')
      analytics.settingsUpdated();

    if(this.source.slice(0,6) == 'email_')
      analytics.unsubscribeInitiated(this.source.slice(6,this.source.length));
  }

});

